From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 15/58] pcmcia/electra_cf: Convert timers to use timer_setup()
Date: Mon, 16 Oct 2017 17:28:59 -0700
Message-ID: <1508200182-104605-16-git-send-email-keescook@chromium.org>
References: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Kees Cook <keescook@chromium.org>, Michael Ellerman <mpe@ellerman.id.au>,
 linux-pcmcia@lists.infradead.org, linux-kernel@vger.kernel.org,
 netdev@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-pcmcia-bounces+glkpd-linux-pcmcia=m.gmane.org@lists.infradead.org>
In-Reply-To: <1508200182-104605-1-git-send-email-keescook@chromium.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-pcmcia>,
 <mailto:linux-pcmcia-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-pcmcia/>
List-Post: <mailto:linux-pcmcia@lists.infradead.org>
List-Help: <mailto:linux-pcmcia-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-pcmcia>,
 <mailto:linux-pcmcia-request@lists.infradead.org?subject=subscribe>
Sender: "linux-pcmcia" <linux-pcmcia-bounces@lists.infradead.org>
Errors-To: linux-pcmcia-bounces+glkpd-linux-pcmcia=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: linux-pcmcia@lists.infradead.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/pcmcia/electra_cf.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/pcmcia/electra_cf.c b/drivers/pcmcia/electra_cf.c
index c6fe2a4a7a6a..9671ded549f0 100644
--- a/drivers/pcmcia/electra_cf.c
+++ b/drivers/pcmcia/electra_cf.c
@@ -79,9 +79,9 @@ static int electra_cf_ss_init(struct pcmcia_socket *s)
 }
 
 /* the timer is primarily to kick this socket's pccardd */
-static void electra_cf_timer(unsigned long _cf)
+static void electra_cf_timer(struct timer_list *t)
 {
-	struct electra_cf_socket *cf = (void *) _cf;
+	struct electra_cf_socket *cf = from_timer(cf, t, timer);
 	int present = electra_cf_present(cf);
 
 	if (present != cf->present) {
@@ -95,7 +95,9 @@ static void electra_cf_timer(unsigned long _cf)
 
 static irqreturn_t electra_cf_irq(int irq, void *_cf)
 {
-	electra_cf_timer((unsigned long)_cf);
+	struct electra_cf_socket *cf = _cf;
+
+	electra_cf_timer(&cf->timer);
 	return IRQ_HANDLED;
 }
 
@@ -206,7 +208,7 @@ static int electra_cf_probe(struct platform_device *ofdev)
 	if (!cf)
 		return -ENOMEM;
 
-	setup_timer(&cf->timer, electra_cf_timer, (unsigned long)cf);
+	timer_setup(&cf->timer, electra_cf_timer, 0);
 	cf->irq = 0;
 
 	cf->ofdev = ofdev;
@@ -305,7 +307,7 @@ static int electra_cf_probe(struct platform_device *ofdev)
 		 cf->mem_phys, io.start, cf->irq);
 
 	cf->active = 1;
-	electra_cf_timer((unsigned long)cf);
+	electra_cf_timer(&cf->timer);
 	return 0;
 
 fail3:
-- 
2.7.4
