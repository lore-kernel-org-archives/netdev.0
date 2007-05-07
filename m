From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: [patch 25/29] xen: Add the Xen virtual network device driver.
Date: Mon, 07 May 2007 14:11:36 -0700
Message-ID: <463F9608.40803@goop.org>
References: <20070504232051.411946839@goop.org> <20070504232121.492190579@goop.org> <20070505091624.GA8890@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@infradead.org>,
	Jeremy Fitzhardinge <jeremy@goop.org>, Andi Kleen <ak@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	virtualization@lists.osdl.org, lkml <linux-kernel@vger.kernel.org>,
	Chris Wright <chrisw@sous-sol.org>,
	Ian Pratt <ian.pratt@xensource.com>,
	Christian Limpach <Christian.Limpach@cl.cam.ac.uk>,
	netdev@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	Stephen Hemminger <shemminge@linux-foundation.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.goop.org ([64.81.55.164]:54327 "EHLO mail.goop.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754344AbXEGVLk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 May 2007 17:11:40 -0400
In-Reply-To: <20070505091624.GA8890@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christoph Hellwig wrote:
> On Fri, May 04, 2007 at 04:21:16PM -0700, Jeremy Fitzhardinge wrote:
>   
>> +/*
>> + * Mutually-exclusive module options to select receive data path:
>> + *  rx_copy : Packets are copied by network backend into local memory
>> + *  rx_flip : Page containing packet data is transferred to our ownership
>> + * For fully-virtualised guests there is no option - copying must be used.
>> + * For paravirtualised guests, flipping is the default.
>> + */
>> +static enum {
>> +	RX_COPY = 0,
>> +	RX_FLIP = 1,
>> +} rx_mode = RX_FLIP;
>> +MODULE_PARM_DESC(rx_mode, "How to get packets from card: 0->copy, 1->flip");
>>     
>
> There only seems to be a module description but no actual paramter for
> this.  I wish people would have listened to me back then and made the
> description part of the modular_param statement..

Is this correct?

---
 drivers/net/xen-netfront.c |   32 ++++++++++++++++++++++++++++----
 1 file changed, 28 insertions(+), 4 deletions(-)

===================================================================
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -62,16 +62,40 @@ struct netfront_cb {
 
 /*
  * Mutually-exclusive module options to select receive data path:
- *  rx_copy : Packets are copied by network backend into local memory
- *  rx_flip : Page containing packet data is transferred to our ownership
+ *  copy : Packets are copied by network backend into local memory
+ *  flip : Page containing packet data is transferred to our ownership
  * For fully-virtualised guests there is no option - copying must be used.
  * For paravirtualised guests, flipping is the default.
  */
-static enum {
+static enum rx_mode {
 	RX_COPY = 0,
 	RX_FLIP = 1,
 } rx_mode = RX_FLIP;
-MODULE_PARM_DESC(rx_mode, "How to get packets from card: 0->copy, 1->flip");
+MODULE_PARM_DESC(rx_mode, "How to get packets from card: \"copy\" or \"flip\"");
+
+static int set_rx_mode(const char *val, struct kernel_param *kp)
+{
+	enum rx_mode *rxmp = kp->arg;
+	int ret = 0;
+
+	if (strcmp(val, "copy") == 0)
+		*rxmp = RX_COPY;
+	else if (strcmp(val, "flip") == 0)
+		*rxmp = RX_FLIP;
+	else
+		ret = -EINVAL;
+
+	return ret;
+}
+
+static int get_rx_mode(char *buffer, struct kernel_param *kp)
+{
+	enum rx_mode *rxmp = kp->arg;
+
+	return sprintf(buffer, "%s", *rxmp == RX_COPY ? "copy" : "flip");
+}
+
+module_param_call(rx_mode, set_rx_mode, get_rx_mode, &rx_mode, 0400);
 
 #define RX_COPY_THRESHOLD 256
 

