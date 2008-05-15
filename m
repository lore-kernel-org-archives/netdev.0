From: Jeff Garzik <jeff@garzik.org>
Subject: [PATCH] Re: [PATCH] drivers/net: remove network drivers' last few
 uses of IRQF_SAMPLE_RANDOM
Date: Thu, 15 May 2008 15:55:38 -0400
Message-ID: <482C953A.4080205@garzik.org>
References: <Pine.LNX.4.62.0805150009060.18303@ikari.dreamhost.com>	<20080515142154.0595e475@core>	<36D9DB17C6DE9E40B059440DB8D95F52052D71BB@orsmsx418.amr.corp.intel.com> <20080515173939.1ec968be@core> <482C7DA3.1090809@garzik.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050705040308050407000605"
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Chris Peterson <cpeterso@cpeterso.com>,
	tpmdd-devel@lists.sourceforge.net, tpm@selhorst.net,
	Herbert Xu <herbert@gondor.apana.org.au>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:51285 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764914AbYEOTzn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2008 15:55:43 -0400
In-Reply-To: <482C7DA3.1090809@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050705040308050407000605
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Jeff Garzik wrote:
> Someone (hi Jesse?) should implement support for TPM_GetRandom.

Here's an example patch (compile-tested only) to get people started.

This function calls the TPM command, and returns TPM header + RNG data 
in the supplied buffer.

A hw_random driver for TPM still needs to (a) parse the TPM header for 
return code, (b) extract RNG bytes out at offset 14, and (c) figure out 
some way to get a tpm_chip pointer.

Spec at 
https://www.trustedcomputinggroup.org/specs/TPM/TCPA_Main_TCG_Architecture_v1_1b.pdf 
describes TPM_GetRandom on page 215.

	Jeff



--------------050705040308050407000605
Content-Type: text/plain;
 name="patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch"

diff --git a/drivers/char/tpm/tpm.c b/drivers/char/tpm/tpm.c
index a5d8bcb..4c3963b 100644
--- a/drivers/char/tpm/tpm.c
+++ b/drivers/char/tpm/tpm.c
@@ -579,6 +579,31 @@ void tpm_continue_selftest(struct tpm_chip *chip)
 }
 EXPORT_SYMBOL_GPL(tpm_continue_selftest);
 
+int tpm_getrandom(struct tpm_chip *chip, void *buf, size_t buflen)
+{
+	u8 rng_cmd[] = {
+		0, 193,			/* TPM_TAG_RQU_COMMAND */
+		0, 0, 0, 14,		/* length */
+		0, 0, 0, 70,		/* TPM_ORD_GetRandom */
+		0, 0, 0, 0,		/* number of bytes to return */
+	};
+	size_t tmp;
+
+	if (buflen <= sizeof(rng_cmd))
+		return -ENOSPC;
+
+	/* patch in requested/returned byte count.  TODO: more than 8-bit */
+	tmp = buflen - sizeof(rng_cmd);
+	if (tmp > 255)
+		tmp = 255;
+	rng_cmd[13] = tmp;
+
+	memcpy(buf, rng_cmd, sizeof(rng_cmd));
+
+	return tpm_transmit(chip, buf, buflen);
+}
+EXPORT_SYMBOL_GPL(tpm_getrandom);
+
 ssize_t tpm_show_enabled(struct device * dev, struct device_attribute * attr,
 			char *buf)
 {
diff --git a/drivers/char/tpm/tpm.h b/drivers/char/tpm/tpm.h
index e885148..bbab3c8 100644
--- a/drivers/char/tpm/tpm.h
+++ b/drivers/char/tpm/tpm.h
@@ -127,6 +127,7 @@ static inline void tpm_write_index(int base, int index, int value)
 extern void tpm_get_timeouts(struct tpm_chip *);
 extern void tpm_gen_interrupt(struct tpm_chip *);
 extern void tpm_continue_selftest(struct tpm_chip *);
+extern int tpm_getrandom(struct tpm_chip *, void *, size_t);
 extern unsigned long tpm_calc_ordinal_duration(struct tpm_chip *, u32);
 extern struct tpm_chip* tpm_register_hardware(struct device *,
 				 const struct tpm_vendor_specific *);

--------------050705040308050407000605--
