From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: [patch 25/29] xen: Add the Xen virtual network device driver.
Date: Mon, 07 May 2007 23:30:10 -0700
Message-ID: <464018F2.7050409@goop.org>
References: <20070504232051.411946839@goop.org>	
	<20070504232121.492190579@goop.org>
	<20070505091624.GA8890@infradead.org>	 <463F9608.40803@goop.org>
	<1178577322.28438.16.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Chris Wright <chrisw@sous-sol.org>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Jeff Garzik <jeff@garzik.org>, Ian Pratt <ian.pratt@xensource.com>,
        netdev@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>,
        Christoph Hellwig <hch@infradead.org>, virtualization@lists.osdl.org,
        Stephen Hemminger <shemminge@linux-foundation.org>,
        Andrew Morton <akpm@linux-foundation.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1178577322.28438.16.camel@localhost.localdomain>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Rusty Russell wrote:
> Looks good, you can slightly improve it to be the model use of new
> module_param types by calling your functions param_set_rx_mode and
> param_get_rx_mode, then simply using "module_param(rx_mode, rx_mode,
> 0400)"
>   

Cute.  I tried it out, but it doesn't yield an obvious improvement:

diff -r 83d67449bff4 drivers/net/xen-netfront.c
--- a/drivers/net/xen-netfront.c	Mon May 07 18:44:11 2007 -0700
+++ b/drivers/net/xen-netfront.c	Mon May 07 22:58:36 2007 -0700
@@ -67,13 +67,16 @@ struct netfront_cb {
  * For fully-virtualised guests there is no option - copying must be used.
  * For paravirtualised guests, flipping is the default.
  */
-static enum rx_mode {
+typedef enum rx_mode {
 	RX_COPY = 0,
 	RX_FLIP = 1,
-} rx_mode = RX_FLIP;
-MODULE_PARM_DESC(rx_mode, "How to get packets from card: \"copy\" or \"flip\"");
-
-static int set_rx_mode(const char *val, struct kernel_param *kp)
+} rx_mode_t;
+
+static enum rx_mode rx_mode = RX_FLIP;
+
+#define param_check_rx_mode_t(name, p) __param_check(name, p, rx_mode_t)
+
+static int param_set_rx_mode_t(const char *val, struct kernel_param *kp)
 {
 	enum rx_mode *rxmp = kp->arg;
 	int ret = 0;
@@ -88,14 +91,15 @@ static int set_rx_mode(const char *val, 
 	return ret;
 }
 
-static int get_rx_mode(char *buffer, struct kernel_param *kp)
+static int param_get_rx_mode_t(char *buffer, struct kernel_param *kp)
 {
 	enum rx_mode *rxmp = kp->arg;
 
 	return sprintf(buffer, "%s", *rxmp == RX_COPY ? "copy" : "flip");
 }
 
-module_param_call(rx_mode, set_rx_mode, get_rx_mode, &rx_mode, 0400);
+MODULE_PARM_DESC(rx_mode, "How to get packets from card: \"copy\" or \"flip\"");
+module_param(rx_mode, rx_mode_t, 0400);
 
 #define RX_COPY_THRESHOLD 256
