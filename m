From: Krzysztof Mazur <krzysiek@podlesie.net>
Subject: Re: [PATCH] br2684: don't send frames on not-ready vcc
Date: Wed, 28 Nov 2012 09:08:04 +0100
Message-ID: <20121128080804.GA23175@shrek.podlesie.net>
References: <1350926091-12642-1-git-send-email-krzysiek@podlesie.net>
 <1350926091-12642-3-git-send-email-krzysiek@podlesie.net>
 <1354036592.2534.6.camel@shinybook.infradead.org>
 <20121127173906.GA11390@shrek.podlesie.net>
 <1354039349.2534.11.camel@shinybook.infradead.org>
 <20121127135434.0728cd4f@thirdoffive.cmf.nrl.navy.mil>
 <1354055783.2534.18.camel@shinybook.infradead.org>
 <1354058916.2534.25.camel@shinybook.infradead.org>
 <20121127235129.GA20080@shrek.podlesie.net>
 <1354064086.21562.10.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>,
	davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, nathan@traverse.com.au
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1354064086.21562.10.camel@shinybook.infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 28, 2012 at 12:54:46AM +0000, David Woodhouse wrote:
> On Wed, 2012-11-28 at 00:51 +0100, Krzysztof Mazur wrote:
> > If you do this actually it's better to don't use patch 1/7 because
> > it introduces race condition that you found earlier.
> 
> Right. I've omitted that from the git tree I just pushed out.
> 
> > With this patch you have still theoretical race that was fixed in patches
> > 5 and 8 in pppoatm series, but I never seen that in practice.
> 
> And I think it's even less likely for br2684. At least with pppoatm you
> might have had pppd sending frames. But for br2684 they *only* come from
> its start_xmit function... which is serialised anyway.
> 
> I do get strange oopses when I try to add BQL to br2684, but that's not
> something to be looking at at 1am...
> 
> I *do* need the equivalent of your patch 4, which is the module_put
> race.
> 

I think you might need also an equivalent of
"[PATCH v3 3/7] pppoatm: allow assign only on a connected socket".

I'm not sure yet. In will test if I can trigger that Oops on pppoatm
without that patch. Testing vcc flags might be sufficient - that's
what I did in the first patch, but you asked what about SOCK_CONNECTED,
and I think it was really needed.

Krzysiek
-- >8 --
Subject: [PATCH] br2684: allow assign only on a connected socket

The br2684 does not check if used vcc is in connected state,
causing potential Oops in pppoatm_send() when vcc->send() is called
on not fully connected socket.

Now br2684 can be assigned only on connected sockets; otherwise
-EINVAL error is returned.

Signed-off-by: Krzysztof Mazur <krzysiek@podlesie.net>
---
 net/atm/br2684.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/atm/br2684.c b/net/atm/br2684.c
index 59e8edb..e88998c 100644
--- a/net/atm/br2684.c
+++ b/net/atm/br2684.c
@@ -704,10 +704,13 @@ static int br2684_ioctl(struct socket *sock, unsigned int cmd,
 			return -ENOIOCTLCMD;
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
-		if (cmd == ATM_SETBACKEND)
+		if (cmd == ATM_SETBACKEND) {
+			if (sock->state != SS_CONNECTED)
+				return -EINVAL;
 			return br2684_regvcc(atmvcc, argp);
-		else
+		} else {
 			return br2684_create(argp);
+		}
 #ifdef CONFIG_ATM_BR2684_IPFILTER
 	case BR2684_SETFILT:
 		if (atmvcc->push != br2684_push)
-- 
1.8.0.411.g71a7da8
