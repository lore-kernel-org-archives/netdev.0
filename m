From: Alex Sidorenko <alexandre.sidorenko@hp.com>
Subject: SWS for rcvbuf < MTU
Date: Fri, 2 Mar 2007 11:28:28 -0500
Message-ID: <200703021128.29208.alexandre.sidorenko@hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:44200 "EHLO atlrel9.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992556AbXCBQvh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 11:51:37 -0500
Received: from l3107tux.atl.hp.com (l3107tux.atl.hp.com [15.19.254.15])
	by atlrel9.hp.com (Postfix) with ESMTP id 57B8A34BD0
	for <netdev@vger.kernel.org>; Fri,  2 Mar 2007 11:28:19 -0500 (EST)
Received: from [15.244.201.199] (unknown [15.244.201.199])
	by l3107tux.atl.hp.com (Postfix) with ESMTP id CD820B2F84
	for <netdev@vger.kernel.org>; Fri,  2 Mar 2007 11:28:18 -0500 (EST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

this is a rare corner case met by one of HP partners on 2.4.20 on IA64. 
Inspecting the sources of the latest 2.6.20.1 (net/ipv4/tcp_output.c) we can 
see that the bug is still there.

Here is a description of the bug and the suggested fix.

The problem occurs when the remote host (not necessarily Linux - in our case 
it was Solaris) does not implement SWS avoidance on sender side. If Linux 
connection socket has rcvbuf<mtu, we can potentially advertise small rcv_wnd 
for a long time (SWS).

The problem is due to SWS avoidance as implemented in __tcp_select_window(). 
Everything works fine when rcvbuf > mtu. But if we use small rcvbuf (set by 
SO_RCVBUF), we can go into SWS mode. Let us for simplicity look only at the 
case when we don't have WS enabled. If we have free_space above full_space/2, 
we reach the following section:


        /* Don't do rounding if we are using window scaling, since the
         * scaled window will not line up with the MSS boundary anyway.
         */
        window = tp->rcv_wnd;
        if (tp->rx_opt.rcv_wscale) {
	    <snip>
        } else {
                /* Get the largest window that is a nice multiple of mss.
                 * Window clamp already applied above.
                 * If our current window offering is within 1 mss of the
                 * free space we just keep it. This prevents the divide
                 * and multiply from happening most of the time.
                 * We also don't do any window rounding when the free space
                 * is too small.
                 */
(1)              if (window <= free_space - mss || window > free_space)
                        window = (free_space/mss)*mss;
        }

        return window;

What happens if we have a small tp->rcv_wnd and rcvbuf <= mss? In this case 
condition (1) is almost always false and as a result we'll return 
unmodified 'window' set to tp->rcv_wnd.  If tp->rcv_wnd is small, it can be 
reused over and over again.

For the case rcvbuf <= mss  __tcp_select_window() returns:

  0		if we have free_space < full_space/2	OK
  mss		if rcvbuf is empty			OK
  tp->rcv_wnd	in other case				Bad


If there is no SWS avoidance on sender side, we can see Linux advertising the 
same small rcv_wnd over and over again. The problem here is that we never 
advertise one-half the receiver's buffer space as described e.g. in

"TCP/IP Illustrated" by Stevens (v.1, Chapter 22.3):

"The normal algorithm is for the receiver not to advertise a larger window 
than it is currently advertising (which can be 0) until the window can be 
increased by either one full-sized segment (i.e. the MSS being received) or by 
one-half the receiver's buffer space, whichever is smaller"
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The fix.
--------

We have not been able to reproduce the problem inside HP as it is unclear what 
conditions are needed to bring system into SWS mode (this needs very special 
event timing). HP customer was seeing it every 2-3 days while running a 
custom application (Solaris<->Linux) that was running with low priority on a 
busy host running other custom applications with SCHED_RR. After going into 
SWS mode, his application stayed in it until restarted.

We provided to customer a fix for 2.4.20 only (used by customer in production) 
by adding another test and returning rcvbuf/2 when needed:

--- net/ipv4/tcp_output.c.orig  Wed May  3 20:40:43 2006
+++ net/ipv4/tcp_output.c       Tue Jan 30 14:24:56 2007
@@ -641,6 +641,7 @@
  * Note, we don't "adjust" for TIMESTAMP or SACK option bytes.
  * Regular options like TIMESTAMP are taken into account.
  */
+static const char *SWS_id_string="@#SWS-fix-2";
 u32 __tcp_select_window(struct sock *sk)
 {
        struct tcp_opt *tp = &sk->tp_pinfo.af_tcp;
@@ -682,6 +683,9 @@
        window = tp->rcv_wnd;
        if (window <= free_space - mss || window > free_space)
                window = (free_space/mss)*mss;
+        /* A fix for small rcvbuf asid@hp.com */
+       else if (mss == full_space && window < full_space/2)
+               window = full_space/2;

        return window;
 }


Customer has confirmed that this resolves the problem and decreases CPU usage 
by  his custom application - even when there is no SWS.


This is a rare corner case and most users will never meet it. But as the fix 
is trivial, I think it makes sense to include it in upstream sources. 

Regards,
Alex

-- 
------------------------------------------------------------------
Alexandre Sidorenko             email: alexs@hplinux.canada.hp.com
Global Solutions Engineering:   Unix Networking
Hewlett-Packard (Canada)
------------------------------------------------------------------
