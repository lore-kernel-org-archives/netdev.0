From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH] ISDN, Gigaset: Fix memory leak in do_disconnect_req()
Date: Sun, 26 Dec 2010 20:59:58 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1012262053130.20797@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Tilman Schmidt <tilman@imap.cc>, Hansjoerg Lipp <hjlipp@web.de>,
	Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: gigaset307x-common@lists.sourceforge.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

In drivers/isdn/gigaset/capi.c::do_disconnect_req() we will leak the 
memory allocated (with kmalloc) to 'b3cmsg' if the call to alloc_skb() 
fails.

...
		b3cmsg = kmalloc(sizeof(*b3cmsg), GFP_KERNEL);
	allocation here ------^
		if (!b3cmsg) {
			dev_err(cs->dev, "%s: out of memory\n", __func__);
			send_conf(iif, ap, skb, CAPI_MSGOSRESOURCEERR);
			return;
		}
		capi_cmsg_header(b3cmsg, ap->id, CAPI_DISCONNECT_B3, CAPI_IND,
				 ap->nextMessageNumber++,
				 cmsg->adr.adrPLCI | (1 << 16));
		b3cmsg->Reason_B3 = CapiProtocolErrorLayer1;
		b3skb = alloc_skb(CAPI_DISCONNECT_B3_IND_BASELEN, GFP_KERNEL);
		if (b3skb == NULL) {
			dev_err(cs->dev, "%s: out of memory\n", __func__);
			send_conf(iif, ap, skb, CAPI_MSGOSRESOURCEERR);
			return;
	leak here ------^
...

This leak is easily fixed by just kfree()'ing the memory allocated to 
'b3cmsg' right before we return. The following patch does that.


Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 capi.c |    1 +
 1 file changed, 1 insertion(+)

  compile tested only since I have no way to actually test this.

diff --git a/drivers/isdn/gigaset/capi.c b/drivers/isdn/gigaset/capi.c
index bcc174e..658e75f 100644
--- a/drivers/isdn/gigaset/capi.c
+++ b/drivers/isdn/gigaset/capi.c
@@ -1900,6 +1900,7 @@ static void do_disconnect_req(struct gigaset_capi_ctr *iif,
 		if (b3skb == NULL) {
 			dev_err(cs->dev, "%s: out of memory\n", __func__);
 			send_conf(iif, ap, skb, CAPI_MSGOSRESOURCEERR);
+			kfree(b3cmsg);
 			return;
 		}
 		capi_cmsg2message(b3cmsg,


-- 
Jesper Juhl <jj@chaosbits.net>            http://www.chaosbits.net/
Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please.
