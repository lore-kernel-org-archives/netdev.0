From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch v2] libertas: potential oops in debugfs
Date: Wed, 30 Oct 2013 20:12:51 +0300
Message-ID: <20131030171251.GA4130@longonot.mountain>
References: <20131025144452.GA28451@ngolde.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: libertas-dev@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131025144452.GA28451@ngolde.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If we do a zero size allocation then it will oops.  Also we can't be
sure the user passes us a NUL terminated string so I've added a
terminator.

This code can only be triggered by root.

Reported-by: Nico Golde <nico@ngolde.de>
Reported-by: Fabian Yamaguchi <fabs@goesec.de>
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/wireless/libertas/debugfs.c b/drivers/net/wireless/libertas/debugfs.c
index 668dd27..1917348 100644
--- a/drivers/net/wireless/libertas/debugfs.c
+++ b/drivers/net/wireless/libertas/debugfs.c
@@ -913,7 +913,10 @@ static ssize_t lbs_debugfs_write(struct file *f, const char __user *buf,
 	char *p2;
 	struct debug_data *d = f->private_data;
 
-	pdata = kmalloc(cnt, GFP_KERNEL);
+	if (cnt == 0)
+		return 0;
+
+	pdata = kmalloc(cnt + 1, GFP_KERNEL);
 	if (pdata == NULL)
 		return 0;
 
@@ -922,6 +925,7 @@ static ssize_t lbs_debugfs_write(struct file *f, const char __user *buf,
 		kfree(pdata);
 		return 0;
 	}
+	pdata[cnt] = '\0';
 
 	p0 = pdata;
 	for (i = 0; i < num_of_items; i++) {
