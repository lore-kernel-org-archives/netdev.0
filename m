From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC v2 1/2] net/hsr: Add support for IEC 62439-3
 High-availability Seamless Redundancy
Date: Tue, 3 Jul 2012 21:20:11 -0700
Message-ID: <20120703212011.4a2e343f@nehalam.linuxnetplumber.net>
References: <4FF38A5C.9000802@xdin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Javier Boticario <jboticario@gmail.com>,
	Bruno Ferreira <balferreira@googlemail.com>
To: Arvid Brodin <Arvid.Brodin@xdin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47402 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750921Ab2GDEUX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jul 2012 00:20:23 -0400
In-Reply-To: <4FF38A5C.9000802@xdin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 4 Jul 2012 00:12:13 +0000
Arvid Brodin <Arvid.Brodin@xdin.com> wrote:

> diff --git a/Documentation/networking/hsr/hsr_genl.c b/Documentation/networking/hsr/hsr_genl.c

1. I like documentation, I like examples, but examples in the Documentation
directory get stale and end up not working.

2. I am not a fan of the non-standard unaligned access optimization.
Stinks too much like the old BSD IFF_TRAILERS thing that still persists
to this day.

3. The code seems to go to a lot of locking effort to get atomic state
   update, if it used the bits in dev_state (ie netif_carrier etc) instead of
   operstate and if_flags I think it would be simpler and safer.  I.e

+static int is_admin_up(struct net_device *dev)
+{
+	return (dev->flags & IFF_UP);
+}
    is redundant with netif_running()

4. Don't use mixed case as in:
     +	HSR_Ver = 0;

5. The header create code has to handle error cases where:
     1. skb must be copied to add header
     2. no space left for header in skb

6. Don't comment out code and then submit it. I don't like reading and
   reviewing leftover debug stuff.

7. Any operations type structure should be declared 'const'. This is safer
   from a security point of view and keeps dirty and immutable variables in separate
   cache areas.

8. If possible use standard netdev macros for printing info messages:
     see netdev_info() etc.

9. Be careful about variable names: "seqlock" implies you are using 
    seq_lock() but you aren't doing that. It is just a spinlock.

10. above() seems like it could be done by signed math in one operation
    without conditional ?: operation.
   See timer_before/timer_after for example.

11. All global variables need to have one prefix.  You are using both hsr_
     and framreg_. Can you just use hsr_?
