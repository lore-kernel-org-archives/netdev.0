From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Fw: [Bug 32322] New: Kernel crashes randomly due to unknown
 reason
Date: Thu, 31 Mar 2011 22:37:21 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.1103312212360.9481@melkinpaasi.cs.helsinki.fi>
References: <20110331084530.187c9145@nehalam>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-534369682-1301600241=:9481"
Cc: Netdev <netdev@vger.kernel.org>
To: henrick19777@yahoo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:58313 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753796Ab1CaThX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2011 15:37:23 -0400
In-Reply-To: <20110331084530.187c9145@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-534369682-1301600241=:9481
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT

On Thu, 31 Mar 2011, Stephen Hemminger wrote:

> Begin forwarded message:
> 
> Date: Thu, 31 Mar 2011 08:22:53 GMT
> From: bugzilla-daemon@bugzilla.kernel.org
> To: shemminger@linux-foundation.org
> Subject: [Bug 32322] New: Kernel crashes randomly due to unknown reason
> 
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=32322
> 
>            Summary: Kernel crashes randomly due to unknown reason
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.37.2
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: henrick19777@yahoo.com
>         Regression: No
> 
> 
> Created an attachment (id=52732)
>  --> (https://bugzilla.kernel.org/attachment.cgi?id=52732)
> kernel config file
> 
> Got a second kernel panic on this machine just randomly after ~26 days of
> uptime. This server runs Debian Squeeze with vsftpd, rsync and apache2 services
> installed from repositories. Here is the crash log:
> 
>  ------------[ cut here ]------------
> kernel BUG at net/ipv4/tcp_output.c:994!

BUG(len < skb->len); it seems...

len = (packets-oldcount) * gso_size, but:

oldcnt < packets < cnt == oldcnt + pcount.

...I'd say there has to be some other invariant violated as skb should 
always have length of at least gso_size * (pcount-1) + 1?

> invalid opcode: 0000 [#1] SMP
> last sysfs file: /sys/devices/pci0000:05/0000:05:07.1/local_cpus
> Modules linked in:
> 
> Pid: 0, comm: kworker/0:1 Not tainted 2.6.37.2-hid3 #2 IBM eserver xSeries 235
> -
> [8671MAX]-/
> EIP: 0060:[<c11c7f53>] EFLAGS: 00010206 CPU: 3
> EIP is at tcp_fragment+0x15/0x239
> EAX: c039ee00 EBX: f40e1200 ECX: 00003de0 EDX: f40e1200
> ESI: f40e1200 EDI: c039ee00 EBP: 00003880 ESP: f50b7dd8
>  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
> Process kworker/0:1 (pid: 0, ti=f50b6000 task=f50b1bc0 task.ti=f50b2000)
> Stack:
>  00003de0 00000286 c102841f c039ee00 f40e1200 f40e1218 00000023 c11c132d
>  000005a0 00000000 00000002 c039ee7c 00000001 c039ee00 0000072e 00000000
>  c11c57f6 00000001 00000001 00000000 00000001 00000026 00000006 c039ee7c
> Call Trace:
>  [<c102841f>] ? __mod_timer+0xe3/0xec
>  [<c11c132d>] ? tcp_mark_head_lost+0x100/0x1a4


...Another point... this particular check has unnecessarily high severity 
as the callers need to be prepared to failures anyway... A patch below 
(but this doesn't resolve the actual issue).

Yet another point, I suppose is should also be changed to check for 
equality as then there isn't any point in calling fragment, but I don't 
think it makes difference here now.

-- 
 i.

--
[PATCH] tcp: len check is unnecessarily devastating, change to WARN_ON

All callers are prepared to alloc failures anyway, so this error
can safely be boomeranged to the callers domain without super
bad consequences. ...At worst the connection might go into a state
where each RTO tries to (unsuccessfully) re-fragment with such
a mis-sized value and eventually dies.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_output.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index dfa5beb..8b0d016 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1003,7 +1003,8 @@ int tcp_fragment(struct sock *sk, struct sk_buff *skb, u32 len,
 	int nlen;
 	u8 flags;
 
-	BUG_ON(len > skb->len);
+	if (WARN_ON(len > skb->len))
+		return -EINVAL;
 
 	nsize = skb_headlen(skb) - len;
 	if (nsize < 0)
-- 
1.7.2.5

--8323329-534369682-1301600241=:9481--
