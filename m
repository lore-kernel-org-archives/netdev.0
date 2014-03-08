From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH RFC net-next v1 3/9] ptp: expose the programmable pins via sysfs
Date: Sat,  8 Mar 2014 20:42:03 +0100
Message-ID: <9d1a85bc294510dcf987236d3e8b20217341cc6a.1394307304.git.richardcochran@gmail.com>
References: <cover.1394307303.git.richardcochran@gmail.com>
Cc: <linux-kernel@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Christian Riesch <christian.riesch@omicron.at>,
	David Miller <davem@davemloft.net>,
	=?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1394307303.git.richardcochran@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds the sysfs hooks needed in order to get and set the
programmable pin settings.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 Documentation/ABI/testing/sysfs-ptp |   20 +++++++
 drivers/ptp/ptp_private.h           |    3 +
 drivers/ptp/ptp_sysfs.c             |  109 +++++++++++++++++++++++++++++++++++
 3 files changed, 132 insertions(+)

diff --git a/Documentation/ABI/testing/sysfs-ptp b/Documentation/ABI/testing/sysfs-ptp
index 05aeedf..44806a6 100644
--- a/Documentation/ABI/testing/sysfs-ptp
+++ b/Documentation/ABI/testing/sysfs-ptp
@@ -54,6 +54,26 @@ Description:
 		This file contains the number of programmable periodic
 		output channels offered by the PTP hardware clock.
 
+What:		/sys/class/ptp/ptpN/n_pins
+Date:		March 2014
+Contact:	Richard Cochran <richardcochran@gmail.com>
+Description:
+		This file contains the number of programmable pins
+		offered by the PTP hardware clock.
+
+What:		/sys/class/ptp/ptpN/pins
+Date:		March 2014
+Contact:	Richard Cochran <richardcochran@gmail.com>
+Description:
+		This directory contains one file for each programmable
+		pin offered by the PTP hardware clock. The file name
+		is the hardware dependent pin name. Reading from this
+		file produces two numbers, the assigned function (see
+		the PTP_PF_ enumeration values in linux/ptp_clock.h)
+		and the channel number. The function and channel
+		assignment may be changed by two writing numbers into
+		the file.
+
 What:		/sys/class/ptp/ptpN/pps_avaiable
 Date:		September 2010
 Contact:	Richard Cochran <richardcochran@gmail.com>
diff --git a/drivers/ptp/ptp_private.h b/drivers/ptp/ptp_private.h
index 253e942..fb7c6b1 100644
--- a/drivers/ptp/ptp_private.h
+++ b/drivers/ptp/ptp_private.h
@@ -51,6 +51,9 @@ struct ptp_clock {
 	struct mutex pincfg_mux; /* protect concurrent info->pin_config access */
 	wait_queue_head_t tsev_wq;
 	int defunct; /* tells readers to go away when clock is being removed */
+	struct device_attribute *pin_dev_attr;
+	struct attribute **pin_attr;
+	struct attribute_group pin_attr_group;
 };
 
 /*
diff --git a/drivers/ptp/ptp_sysfs.c b/drivers/ptp/ptp_sysfs.c
index 13ec531..4495c4d 100644
--- a/drivers/ptp/ptp_sysfs.c
+++ b/drivers/ptp/ptp_sysfs.c
@@ -18,6 +18,7 @@
  *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  */
 #include <linux/capability.h>
+#include <linux/slab.h>
 
 #include "ptp_private.h"
 
@@ -42,6 +43,7 @@ PTP_SHOW_INT(max_adjustment, max_adj);
 PTP_SHOW_INT(n_alarms, n_alarm);
 PTP_SHOW_INT(n_external_timestamps, n_ext_ts);
 PTP_SHOW_INT(n_periodic_outputs, n_per_out);
+PTP_SHOW_INT(n_programmable_pins, n_pins);
 PTP_SHOW_INT(pps_available, pps);
 
 static struct attribute *ptp_attrs[] = {
@@ -50,6 +52,7 @@ static struct attribute *ptp_attrs[] = {
 	&dev_attr_n_alarms.attr,
 	&dev_attr_n_external_timestamps.attr,
 	&dev_attr_n_periodic_outputs.attr,
+	&dev_attr_n_programmable_pins.attr,
 	&dev_attr_pps_available.attr,
 	NULL,
 };
@@ -175,6 +178,60 @@ out:
 	return err;
 }
 
+static int ptp_pin_name2index(struct ptp_clock *ptp, const char *name)
+{
+	int i;
+	for (i = 0; i < ptp->info->n_pins; i++) {
+		if (!strcmp(ptp->info->pin_config[i].name, name))
+			return i;
+	}
+	return -1;
+}
+
+static ssize_t ptp_pin_show(struct device *dev, struct device_attribute *attr,
+			    char *page)
+{
+	struct ptp_clock *ptp = dev_get_drvdata(dev);
+	unsigned int func, chan;
+	int index;
+
+	index = ptp_pin_name2index(ptp, attr->attr.name);
+	if (index < 0)
+		return -EINVAL;
+
+	if (mutex_lock_interruptible(&ptp->pincfg_mux))
+		return -ERESTARTSYS;
+
+	func = ptp->info->pin_config[index].func;
+	chan = ptp->info->pin_config[index].chan;
+
+	mutex_unlock(&ptp->pincfg_mux);
+
+	return snprintf(page, PAGE_SIZE, "%u %u\n", func, chan);
+}
+
+static ssize_t ptp_pin_store(struct device *dev, struct device_attribute *attr,
+			     const char *buf, size_t count)
+{
+	struct ptp_clock *ptp = dev_get_drvdata(dev);
+	unsigned int func, chan;
+	int cnt, err, index;
+
+	cnt = sscanf(buf, "%u %u", &func, &chan);
+	if (cnt != 2)
+		return -EINVAL;
+
+	index = ptp_pin_name2index(ptp, attr->attr.name);
+	if (index < 0)
+		return -EINVAL;
+
+	err = ptp_setpin(ptp, index, func, chan);
+	if (err)
+		return err;
+
+	return count;
+}
+
 static DEVICE_ATTR(extts_enable, 0220, NULL, extts_enable_store);
 static DEVICE_ATTR(fifo,         0444, extts_fifo_show, NULL);
 static DEVICE_ATTR(period,       0220, NULL, period_store);
@@ -195,7 +252,54 @@ int ptp_cleanup_sysfs(struct ptp_clock *ptp)
 	if (info->pps)
 		device_remove_file(dev, &dev_attr_pps_enable);
 
+	if (info->n_pins) {
+		sysfs_remove_group(&dev->kobj, &ptp->pin_attr_group);
+		kfree(ptp->pin_attr);
+		kfree(ptp->pin_dev_attr);
+	}
+	return 0;
+}
+
+static int ptp_populate_pins(struct ptp_clock *ptp)
+{
+	struct device *dev = ptp->dev;
+	struct ptp_clock_info *info = ptp->info;
+	int err = -ENOMEM, i, n_pins = info->n_pins;
+
+	ptp->pin_dev_attr = kzalloc(n_pins * sizeof(*ptp->pin_dev_attr),
+				    GFP_KERNEL);
+	if (!ptp->pin_dev_attr)
+		goto no_dev_attr;
+
+	ptp->pin_attr = kzalloc((1 + n_pins) * sizeof(struct attribute *),
+				GFP_KERNEL);
+	if (!ptp->pin_attr)
+		goto no_pin_attr;
+
+	for (i = 0; i < n_pins; i++) {
+		struct device_attribute *da = &ptp->pin_dev_attr[i];
+		sysfs_attr_init(&da->attr);
+		da->attr.name = info->pin_config[i].name;
+		da->attr.mode = 0644;
+		da->show = ptp_pin_show;
+		da->store = ptp_pin_store;
+		ptp->pin_attr[i] = &da->attr;
+	}
+
+	ptp->pin_attr_group.name = "pins";
+	ptp->pin_attr_group.attrs = ptp->pin_attr;
+
+	err = sysfs_create_group(&dev->kobj, &ptp->pin_attr_group);
+	if (err)
+		goto no_group;
 	return 0;
+
+no_group:
+	kfree(ptp->pin_attr);
+no_pin_attr:
+	kfree(ptp->pin_dev_attr);
+no_dev_attr:
+	return err;
 }
 
 int ptp_populate_sysfs(struct ptp_clock *ptp)
@@ -222,6 +326,11 @@ int ptp_populate_sysfs(struct ptp_clock *ptp)
 		if (err)
 			goto out4;
 	}
+	if (info->n_pins) {
+		err = ptp_populate_pins(ptp);
+		if (err)
+			goto out4;
+	}
 	return 0;
 out4:
 	if (info->n_per_out)
-- 
1.7.10.4
