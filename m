From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: [RFC] [PATCH 1/7] pcmcia: add pcmcia_loop_config() helper
Date: Tue, 29 Jul 2008 09:15:39 +0200
Message-ID: <20080729071539.GB27385@comet.dominikbrodowski.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tejun Heo <htejun@gmail.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>,
	linux-ide@vger.kernel.org, Marcel Holtmann <marcel@holtmann.org>,
	linux-bluetooth@vger.kernel.org,
	"James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>,
	linux-scsi@vger.kernel.org, Karsten Keil <kkeil@suse.de>,
	isdn4linux@listserv.isdn4linux.de, Jeff Garzik <jgarzik@pobox.com>,
	netdev@vger.kernel.org, Harald Welte <laforge@gnumonks.org>,
	linux-parport@lists.infradead.org,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	Ed Okerson <eokerson@quicknet.net>,
	linux-serial@vger.kernel.org
To: linux-pcmcia@lists.infradead.org
Return-path: <linux-serial-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-serial-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

By calling pcmcia_loop_config(), a pcmcia driver can iterate over all
available configuration options. During a driver's probe() phase, one
doesn't need to use pcmcia_get_{first,next}_tuple, pcmcia_get_tuple_data
and pcmcia_parse_tuple directly in most if not all cases.

Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
---
 Documentation/pcmcia/driver-changes.txt |    6 +++
 drivers/pcmcia/pcmcia_resource.c        |   57 +++++++++++++++++++++++++++++++
 include/pcmcia/cistpl.h                 |    6 +++
 3 files changed, 69 insertions(+), 0 deletions(-)

By calling pcmcia_loop_config(), a pcmcia driver can iterate over all
available configuration options. During a driver's probe() phase, one
doesn't need to use pcmcia_get_{first,next}_tuple, pcmcia_get_tuple_data
and pcmcia_parse_tuple directly in most if not all cases.

Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
---
 Documentation/pcmcia/driver-changes.txt |    6 +++
 drivers/pcmcia/pcmcia_resource.c        |   63 +++++++++++++++++++++++++++++++
 include/pcmcia/cistpl.h                 |    6 +++
 3 files changed, 75 insertions(+), 0 deletions(-)

diff --git a/Documentation/pcmcia/driver-changes.txt b/Documentation/pcmcia/driver-changes.txt
index 96f155e..44085c1 100644
--- a/Documentation/pcmcia/driver-changes.txt
+++ b/Documentation/pcmcia/driver-changes.txt
@@ -1,5 +1,11 @@
 This file details changes in 2.6 which affect PCMCIA card driver authors:
 
+* New configuration loop helper (as of 2.6.28)
+   By calling pcmcia_loop_config(), a driver can iterate over all available
+   configuration options. During a driver's probe() phase, one doesn't need
+   to use pcmcia_get_{first,next}_tuple, pcmcia_get_tuple_data and
+   pcmcia_parse_tuple directly in most if not all cases.  
+
 * New release helper (as of 2.6.17)
    Instead of calling pcmcia_release_{configuration,io,irq,win}, all that's
    necessary now is calling pcmcia_disable_device. As there is no valid
diff --git a/drivers/pcmcia/pcmcia_resource.c b/drivers/pcmcia/pcmcia_resource.c
index 4884a18..0fa48aa 100644
--- a/drivers/pcmcia/pcmcia_resource.c
+++ b/drivers/pcmcia/pcmcia_resource.c
@@ -909,3 +909,66 @@ void pcmcia_disable_device(struct pcmcia_device *p_dev) {
 		pcmcia_release_window(p_dev->win);
 }
 EXPORT_SYMBOL(pcmcia_disable_device);
+
+
+/**
+ * pcmcia_loop_config() - loop over configuration options
+ * @p_dev:	the struct pcmcia_device which we need to loop for.
+ * @conf_check:	function to call for each configuration option.
+ *		It gets passed the struct pcmcia_device, the CIS data
+ *		describing the configuration option, and private data
+ *		being passed to pcmcia_loop_config()
+ * @priv_data:	private data to be passed to the conf_check function.
+ *
+ * pcmcia_loop_config() loops over all configuration options, and calls
+ * the driver-specific conf_check() for each one, checking whether
+ * it is a valid one.
+ */
+
+struct pcmcia_cfg_mem {
+	tuple_t tuple;
+	cisparse_t parse;
+	u8 buf[256];
+};
+
+int pcmcia_loop_config(struct pcmcia_device *p_dev,
+		       int	(*conf_check)	(struct pcmcia_device *p_dev,
+						 cistpl_cftable_entry_t *cfg,
+						 void *priv_data),
+		       void *priv_data)
+{
+	struct pcmcia_cfg_mem *cfg_mem;
+	tuple_t *tuple;
+	int ret = -ENODEV;
+
+	cfg_mem = kzalloc(sizeof(struct pcmcia_cfg_mem), GFP_KERNEL);
+	if (cfg_mem == NULL)
+		return -ENOMEM;
+
+	tuple = &cfg_mem->tuple;
+	tuple->TupleData = cfg_mem->buf;
+	tuple->TupleDataMax = 255;
+	tuple->TupleOffset = 0;
+	tuple->DesiredTuple = CISTPL_CFTABLE_ENTRY;
+	tuple->Attributes = 0;
+
+	ret = pcmcia_get_first_tuple(p_dev, tuple);
+	while (!ret) {
+		if (pcmcia_get_tuple_data(p_dev, tuple))
+			goto next_entry;
+
+		if (pcmcia_parse_tuple(p_dev, tuple, &cfg_mem->parse))
+			goto next_entry;
+
+		ret = conf_check(p_dev, &cfg_mem->parse.cftable_entry,
+				 priv_data);
+		if (!ret)
+			break;
+
+	next_entry:
+		ret = pcmcia_get_next_tuple(p_dev, tuple);
+	}
+
+	return ret;
+}
+EXPORT_SYMBOL(pcmcia_loop_config);
diff --git a/include/pcmcia/cistpl.h b/include/pcmcia/cistpl.h
index 552a332..9830b34 100644
--- a/include/pcmcia/cistpl.h
+++ b/include/pcmcia/cistpl.h
@@ -607,4 +607,10 @@ int pccard_validate_cis(struct pcmcia_socket *s, unsigned int function, unsigned
 #define pcmcia_validate_cis(p_dev, info) \
 		pccard_validate_cis(p_dev->socket, p_dev->func, info)
 
+int pcmcia_loop_config(struct pcmcia_device *p_dev,
+		       int	(*conf_check)	(struct pcmcia_device *p_dev,
+						 cistpl_cftable_entry_t *cf,
+						 void *priv_data),
+		       void *priv_data);
+
 #endif /* LINUX_CISTPL_H */
-- 
1.5.4.3

