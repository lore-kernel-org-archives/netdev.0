From: YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>
Subject: [PATCH v3 2/2] fjes: Do not load fjes driver if extended socket
 device is not power on.
Date: Tue, 21 Mar 2017 11:46:35 -0400
Message-ID: <8730dda8-d4bc-c3f9-01c3-8d0d1026cf5c@gmail.com>
References: <c0bb31ae-1f5b-9b73-ed51-a8d56361ff59@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, izumi.taku@jp.fujitsu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:35161 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756464AbdCUPsE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 11:48:04 -0400
Received: by mail-qk0-f194.google.com with SMTP id o135so22614984qke.2
        for <netdev@vger.kernel.org>; Tue, 21 Mar 2017 08:46:37 -0700 (PDT)
In-Reply-To: <c0bb31ae-1f5b-9b73-ed51-a8d56361ff59@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The extended device socket cannot turn on/off while system is running.
So when system boots up and the device is not power on, the fjes driver
does not need be loaded.

To check the status of the device, the patch adds ACPI _STA method check.

Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
CC: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/net/fjes/fjes_main.c | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/drivers/net/fjes/fjes_main.c b/drivers/net/fjes/fjes_main.c
index 7b58964..ae48c80 100644
--- a/drivers/net/fjes/fjes_main.c
+++ b/drivers/net/fjes/fjes_main.c
@@ -144,6 +144,24 @@ static bool is_extended_socket_device(struct acpi_device *device)
 	return true;
 }

+static int acpi_check_extended_socket_status(struct acpi_device *device)
+{
+	unsigned long long sta;
+	acpi_status status;
+
+	status = acpi_evaluate_integer(device->handle, "_STA", NULL, &sta);
+	if (ACPI_FAILURE(status))
+		return -ENODEV;
+
+	if (!((sta & ACPI_STA_DEVICE_PRESENT) &&
+	      (sta & ACPI_STA_DEVICE_ENABLED) &&
+	      (sta & ACPI_STA_DEVICE_UI) &&
+	      (sta & ACPI_STA_DEVICE_FUNCTIONING)))
+		return -ENODEV;
+
+	return 0;
+}
+
 static int fjes_acpi_add(struct acpi_device *device)
 {
 	struct platform_device *plat_dev;
@@ -152,6 +170,9 @@ static int fjes_acpi_add(struct acpi_device *device)
 	if (!is_extended_socket_device(device))
 		return -ENODEV;

+	if (acpi_check_extended_socket_status(device))
+		return -ENODEV;
+
 	status = acpi_walk_resources(device->handle, METHOD_NAME__CRS,
 				     fjes_get_acpi_resource, fjes_resource);
 	if (ACPI_FAILURE(status))
@@ -1503,6 +1524,9 @@ static void fjes_watch_unshare_task(struct work_struct *work)
 	if (!is_extended_socket_device(device))
 		return AE_OK;

+	if (acpi_check_extended_socket_status(device))
+		return AE_OK;
+
 	*found = true;
 	return AE_CTRL_TERMINATE;
 }
-- 
1.8.3.1


On 03/21/2017 11:28 AM, YASUAKI ISHIMATSU wrote:
> The fjes driver is used only by FUJITSU servers and almost of all
> servers in the world never use it. But currently if ACPI PNP0C02
> is defined in the ACPI table, the following message is always shown:
> 
>  "FUJITSU Extended Socket Network Device Driver - version 1.2
>   - Copyright (c) 2015 FUJITSU LIMITED"
> 
> The message makes users confused because there is no reason that
> the message is shown in other vendor servers.
> 
> To avoid the confusion, the patch adds several checks.
> 
> v3:
>   - Rebase on latest net tree.
>   - Add _STA method check to avoid loading fjes driver.
> 
> v2:
>   - Order local variable declarations from longest to shortest line
> 
> Yasuaki Ishimatsu(2):
>   fjes: Do not load fjes driver if system does not have extended socket device.
>   fjes: Do not load fjes driver if extended socket device is not power on.
> 
>  drivers/net/fjes/fjes_main.c | 76 +++++++++++++++++++++++++++++++++++++++++---
>  1 file changed, 71 insertions(+), 5 deletions(-)
> 
