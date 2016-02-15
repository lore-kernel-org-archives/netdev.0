From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf] netfilter: nfnetlink: correctly validate length of
 batch messages
Date: Mon, 15 Feb 2016 20:27:12 +0100
Message-ID: <20160215192712.GA4116@salvia>
References: <1454438205-13147-1-git-send-email-phil.turnbull@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	"open list:NETFILTER ({IP,IP6,ARP,EB,NF}TABLES)"
	<coreteam@netfilter.org>,
	"open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>,
	open list <linux-kernel@vger.kernel.org>
To: phil.turnbull@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1454438205-13147-1-git-send-email-phil.turnbull@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 02, 2016 at 01:36:45PM -0500, phil.turnbull@oracle.com wrote:
> From: Phil Turnbull <phil.turnbull@oracle.com>
> 
> If nlh->nlmsg_len is zero then an infinite loop is triggered because
> 'skb_pull(skb, msglen);' pulls zero bytes.
> 
> The calculation in nlmsg_len() underflows if 'nlh->nlmsg_len <
> NLMSG_HDRLEN' which bypasses the length validation and will later
> trigger an out-of-bound read.
> 
> If the length validation does fail then the malformed batch message is
> copied back to userspace. However, we cannot do this because the
> nlh->nlmsg_len can be invalid. This leads to an out-of-bounds read in
> netlink_ack:
> 
>     [   41.455421] ==================================================================
>     [   41.456431] BUG: KASAN: slab-out-of-bounds in memcpy+0x1d/0x40 at addr ffff880119e79340
>     [   41.456431] Read of size 4294967280 by task a.out/987
>     [   41.456431] =============================================================================
>     [   41.456431] BUG kmalloc-512 (Not tainted): kasan: bad access detected
>     [   41.456431] -----------------------------------------------------------------------------
>     ...
>     [   41.456431] Bytes b4 ffff880119e79310: 00 00 00 00 d5 03 00 00 b0 fb fe ff 00 00 00 00  ................
>     [   41.456431] Object ffff880119e79320: 20 00 00 00 10 00 05 00 00 00 00 00 00 00 00 00   ...............
>     [   41.456431] Object ffff880119e79330: 14 00 0a 00 01 03 fc 40 45 56 11 22 33 10 00 05  .......@EV."3...
>     [   41.456431] Object ffff880119e79340: f0 ff ff ff 88 99 aa bb 00 14 00 0a 00 06 fe fb  ................
>                                             ^^ start of batch nlmsg with
>                                                nlmsg_len=4294967280
>     ...
>     [   41.456431] Memory state around the buggy address:
>     [   41.456431]  ffff880119e79400: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>     [   41.456431]  ffff880119e79480: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>     [   41.456431] >ffff880119e79500: 00 00 00 00 fc fc fc fc fc fc fc fc fc fc fc fc
>     [   41.456431]                                ^
>     [   41.456431]  ffff880119e79580: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
>     [   41.456431]  ffff880119e79600: fc fc fc fc fc fc fc fc fc fc fb fb fb fb fb fb
>     [   41.456431] ==================================================================
> 
> Fix this with better validation of nlh->nlmsg_len and by setting
> NFNL_BATCH_FAILURE if any batch message fails length validation.
> 
> CAP_NET_ADMIN is required to trigger the bugs.

Applied, thanks.
