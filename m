From: Henrik Austad <henrik@austad.us>
Subject: [very-RFC 7/8] AVB ALSA - Add ALSA shim for TSN
Date: Sun, 12 Jun 2016 01:01:35 +0200
Message-ID: <1465686096-22156-8-git-send-email-henrik@austad.us>
References: <1465686096-22156-1-git-send-email-henrik@austad.us>
Cc: linux-media@vger.kernel.org, alsa-devel@vger.kernel.org,
	netdev@vger.kernel.org, henrk@austad.us,
	Henrik Austad <haustad@cisco.com>,
	Mauro Carvalho Chehab <mchehab@osg.samsung.com>,
	Takashi Iwai <tiwai@suse.de>, Mark Brown <broonie@kernel.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465686096-22156-1-git-send-email-henrik@austad.us>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Henrik Austad <haustad@cisco.com>

This exposes a *very* rudimentary and simplistic ALSA driver that hooks
into TSN to create a device for userspace.

It currently only supports 44.1/48kHz sampling, 2ch, S16_LE

Userspace is supposed to reserve bandwidth, find StreamID etc.

To use as a Talker:

mkdir /config/tsn/test/eth0/talker
cd /config/tsn/test/eth0/talker
echo 65535 > buffer_size
echo 08:00:27:08:9f:c3 > remote_mac
echo 42 > stream_id
echo alsa > enabled

aplay -Ddefault:CARD=avb -c2 -r48000 -fS16_LE /opt/rickroll.wav

The same applies to Listener and arecord.

Cc: Mauro Carvalho Chehab <mchehab@osg.samsung.com>
Cc: Takashi Iwai <tiwai@suse.de>
Cc: Mark Brown <broonie@kernel.org>
Signed-off-by: Henrik Austad <haustad@cisco.com>
---
 drivers/media/Kconfig            |  15 +
 drivers/media/Makefile           |   3 +-
 drivers/media/avb/Makefile       |   5 +
 drivers/media/avb/avb_alsa.c     | 742 +++++++++++++++++++++++++++++++++++++++
 drivers/media/avb/tsn_iec61883.h | 124 +++++++
 5 files changed, 888 insertions(+), 1 deletion(-)
 create mode 100644 drivers/media/avb/Makefile
 create mode 100644 drivers/media/avb/avb_alsa.c
 create mode 100644 drivers/media/avb/tsn_iec61883.h

diff --git a/drivers/media/Kconfig b/drivers/media/Kconfig
index a8518fb..14ad1d9 100644
--- a/drivers/media/Kconfig
+++ b/drivers/media/Kconfig
@@ -217,3 +217,18 @@ source "drivers/media/tuners/Kconfig"
 source "drivers/media/dvb-frontends/Kconfig"
 
 endif # MEDIA_SUPPORT
+
+config MEDIA_AVB_ALSA
+       tristate "ALSA part of AVB over TSN"
+       depends on TSN
+       help
+
+         Enable the ALSA device that hoooks into TSN and allows the
+         computer to send ethernet frames over the network carrying
+         audio-data to selected hosts.
+
+	 This must be configured by userspace as MSRP and IEEE 1722.1
+	 (discovery and enumeration) is not implemented within the
+	 kernel.
+
+	 If unsure, say N
\ No newline at end of file
diff --git a/drivers/media/Makefile b/drivers/media/Makefile
index e608bbc..a1ca09e 100644
--- a/drivers/media/Makefile
+++ b/drivers/media/Makefile
@@ -20,6 +20,7 @@ endif
 
 obj-$(CONFIG_VIDEO_DEV) += v4l2-core/
 obj-$(CONFIG_DVB_CORE)  += dvb-core/
+obj-$(CONFIG_AVB) += avb/
 
 # There are both core and drivers at RC subtree - merge before drivers
 obj-y += rc/
@@ -30,4 +31,4 @@ obj-y += rc/
 
 obj-y += common/ platform/ pci/ usb/ mmc/ firewire/
 obj-$(CONFIG_VIDEO_DEV) += radio/
-
+obj-$(CONFIG_MEDIA_AVB_ALSA) += avb/
diff --git a/drivers/media/avb/Makefile b/drivers/media/avb/Makefile
new file mode 100644
index 0000000..5d6302c
--- /dev/null
+++ b/drivers/media/avb/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for the ALSA shim in AVB/TSN
+#
+
+obj-$(CONFIG_MEDIA_AVB_ALSA) += avb_alsa.o
diff --git a/drivers/media/avb/avb_alsa.c b/drivers/media/avb/avb_alsa.c
new file mode 100644
index 0000000..9aff7d3
--- /dev/null
+++ b/drivers/media/avb/avb_alsa.c
@@ -0,0 +1,742 @@
+/* Copyright 2016 Cisco Systems, Inc. and/or its affiliates. All rights
+ * reserved.
+ *
+ * This program is free software; you may redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; version 2 of the License.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+#include <linux/platform_device.h>
+#include <sound/pcm_params.h>
+#include <linux/module.h>
+#include <linux/slab.h>
+#include <sound/core.h>
+#include <sound/pcm.h>
+
+#include <linux/tsn.h>
+#include "tsn_iec61883.h"
+
+struct avb_chip {
+	struct snd_card *card;
+	struct tsn_link *link;
+	struct snd_pcm *pcm;
+	struct snd_pcm_substream *substream;
+
+	/* Need a reference to this when we unregister the platform
+	 * driver.
+	 */
+	struct platform_device *device;
+
+	/* on first copy, we set a few values, use this to make sure we
+	 * only do this once.
+	 */
+	u8 first_copy;
+
+	u8 sample_size;
+	u8 channels;
+
+	/* current idx in 10ms set of frames
+	 * class A: 80
+	 * class B: 40
+	 *
+	 * This is mostly relevant for 44.1kHz samplefreq
+	 */
+	u8 num_10ms_series;
+
+	u32 sample_freq;
+};
+
+/* currently, only playback is implemented in TSN layer
+ *
+
+ * FIXMEs: (should be set according to the active TSN link)
+ * - format
+ * - rates
+ * - channels
+ */
+static struct snd_pcm_hardware snd_avb_hw = {
+	.info = SNDRV_PCM_INFO_INTERLEAVED,
+	.formats = SNDRV_PCM_FMTBIT_S16_LE,
+	.rates = SNDRV_PCM_RATE_44100 | SNDRV_PCM_RATE_48000,
+	.rate_min = 44100,
+	.rate_max = 48000,
+	.channels_min = 2,
+	.channels_max = 2,
+	.period_bytes_min = 4096,
+	.period_bytes_max = 32768,
+	.buffer_bytes_max = 32768,
+	.periods_min = 1,
+	.periods_max = 1024,
+	.fifo_size   = 0,
+};
+
+static size_t snd_avb_copy_size(struct tsn_link *link);
+
+
+static int _set_chip_values(struct avb_chip *avb_chip,
+			struct snd_pcm_runtime *runtime)
+{
+	if (!avb_chip->first_copy)
+		return 0;
+
+
+	/*
+	 * first copy, we now know that runtime has all the correct
+	 * values set, we can grab channels and rate. Sample_size
+	 * (runtime->format) is currently hard-coded to S16_LE.
+	 */
+	avb_chip->channels = runtime->channels;
+	avb_chip->sample_freq = runtime->rate;
+	avb_chip->sample_size = 16;
+
+	if (snd_avb_copy_size(avb_chip->link) > avb_chip->link->max_payload_size) {
+		pr_err("%s: Resulting payload-size is larger (%zd) than available (%u)\n",
+			__func__, snd_avb_copy_size(avb_chip->link),
+			avb_chip->link->max_payload_size);
+		return -EINVAL;
+	}
+	avb_chip->first_copy = 0;
+	return 0;
+}
+
+static int _snd_avb_open(struct avb_chip *avb_chip,
+			struct snd_pcm_runtime *runtime)
+{
+	/*
+	 * We do not know what some of these values are until we see the
+	 * first copy. We set to sane defaults where we don't have exact
+	 * content.
+	 */
+	avb_chip->channels = 0;
+	avb_chip->sample_size = 0;
+	avb_chip->sample_freq = 0;
+	avb_chip->num_10ms_series = 0;
+	avb_chip->first_copy = 1;
+
+	runtime->hw = snd_avb_hw;
+	runtime->buffer_size = avb_chip->link->buffer_size;
+	return 0;
+}
+
+/*
+ * bytes_to_frames()
+ * frames_to_bytes()
+ *
+ * frames_to_bytes(runtime, runtrime->period_size);
+ *
+ * Interrupt callbacks:
+ * The field traonsfer_ack_begin and transfer_ack_end are called at the
+ * beginning and at the end of snd_pcm_period_elapsed(), respectively.
+ */
+static int snd_avb_playback_open(struct snd_pcm_substream *substream)
+{
+	struct snd_pcm_runtime *runtime = substream->runtime;
+	struct avb_chip *avb_chip = snd_pcm_substream_chip(substream);
+	int ret = 0;
+
+	/*
+	 * we've opened the PCM before probe returned properly and
+	 * stored link in the struct.
+	 */
+	if (!avb_chip || !avb_chip->link) {
+		pr_err("%s: Chip-data or link not available, cannot continue\n",
+			__func__);
+		return -EINVAL;
+	}
+	if (!avb_chip->link->estype_talker) {
+		pr_info("Link (%llu) not registered as Talker, cannot do playback\n",
+			avb_chip->link->stream_id);
+		return -EINVAL;
+	}
+
+	ret = _snd_avb_open(avb_chip, runtime);
+	if (ret < 0) {
+		pr_err("%s: Could not open playback-device (requested %d ch, %zd buffer)",
+			__func__, avb_chip->channels,
+			avb_chip->link->buffer_size);
+		return ret;
+	}
+	pr_info("%s: %d channel PCM stream opened successfully, buffersize: %zd\n",
+		__func__, avb_chip->channels, avb_chip->link->buffer_size);
+	return 0;
+}
+
+static int snd_avb_playback_close(struct snd_pcm_substream *substream)
+{
+	struct avb_chip *avb_chip = snd_pcm_substream_chip(substream);
+
+	tsn_lb_disable(avb_chip->link);
+
+	pr_info("%s: something happened\n", __func__);
+	return 0;
+}
+
+/*
+ * snd_avb snd_avb.0: BUG: ,
+ *		      pos = 12288,
+ *		      buffer size = 8192,
+ *		      period size = 2048
+ *
+ * Playback is when we *send* data to a remote speaker
+ */
+static int snd_avb_playback_copy(struct snd_pcm_substream *substream,
+				int channel,
+				snd_pcm_uframes_t pos,
+				void *src,
+				snd_pcm_uframes_t count)
+{
+	struct snd_pcm_runtime *runtime = substream->runtime;
+	struct avb_chip *avb_chip = snd_pcm_substream_chip(substream);
+	size_t bytes;
+	int ret;
+
+	/*
+	 * From alsadoc:
+	 *
+	 * You need to check the channel argument, and if it's -1, copy
+	 * the whole channels. Otherwise, you have to copy only the
+	 * specified channel. Please check isa/gus/gus_pcm.c as an
+	 * example.
+	 */
+	if (channel != -1) {
+		pr_err("%s: partial copy not supportet\n", __func__);
+		return -EINVAL;
+	}
+
+	ret = _set_chip_values(avb_chip, runtime);
+	if (ret != 0)
+		return ret;
+
+	bytes = frames_to_bytes(runtime, count);
+	ret = tsn_buffer_write(avb_chip->link, src, bytes);
+	if (ret != bytes) {
+		pr_err("%s: Incorrect copy (%zd, %d) corruption possible\n",
+		       __func__, bytes, ret);
+		return -EIO;
+	}
+	return 0;
+}
+
+static int snd_avb_capture_open(struct snd_pcm_substream *substream)
+{
+	struct snd_pcm_runtime *runtime = substream->runtime;
+	struct avb_chip *avb_chip = snd_pcm_substream_chip(substream);
+	int ret = 0;
+
+	if (!avb_chip || !avb_chip->link) {
+		pr_err("%s: Chip-data or link not available, cannot continue\n",
+		       __func__);
+		return -EINVAL;
+	}
+	if (avb_chip->link->estype_talker) {
+		pr_info("Link (%llu) registered as Talker, cannot capture\n",
+			avb_chip->link->stream_id);
+		return -EINVAL;
+	}
+	ret = _snd_avb_open(avb_chip, runtime);
+	if (ret < 0) {
+		pr_err("%s: Could not open capture-device (requested %d ch, %zd buffer)",
+			__func__, avb_chip->channels,
+			avb_chip->link->buffer_size);
+		return ret;
+	}
+	tsn_lb_enable(avb_chip->link);
+	pr_info("%s: %d channel PCM stream opened successfully, buffersize: %zd\n",
+		__func__, avb_chip->channels, avb_chip->link->buffer_size);
+	return 0;
+}
+
+static int snd_avb_capture_close(struct snd_pcm_substream *substream)
+{
+	struct avb_chip *avb_chip = snd_pcm_substream_chip(substream);
+
+	if (!avb_chip || !avb_chip->link)
+		return -EINVAL;
+	pr_err("%s: closing stream\n", __func__);
+
+	tsn_lb_disable(avb_chip->link);
+
+	return 0;
+}
+
+static int snd_avb_capture_copy(struct snd_pcm_substream *substream,
+				int channel,
+				snd_pcm_uframes_t pos,
+				void *src,
+				snd_pcm_uframes_t count)
+{
+	struct snd_pcm_runtime *runtime = substream->runtime;
+	struct avb_chip *avb_chip = snd_pcm_substream_chip(substream);
+	size_t bytes;
+	int ret;
+
+	bytes = frames_to_bytes(runtime, count);
+	ret = tsn_buffer_read(avb_chip->link, src, bytes);
+	if (ret != bytes) {
+		pr_err("%s: incorrect copy (%zd, %d), corrupt capture possible\n",
+			__func__, bytes, ret);
+		tsn_lb_disable(avb_chip->link);
+		return -EIO;
+	}
+	return 0;
+}
+
+static int snd_avb_silence(struct snd_pcm_substream *substream,
+				int channel, snd_pcm_uframes_t pos,
+				snd_pcm_uframes_t count)
+{
+	/* FIXME, should do more than nothing */
+	return 0;
+}
+
+/*
+ * Called when the client defines buffer_size, period_size, format etc
+ * for the pcm substream.
+ *
+ * This is where link->buffer is allocated and link->buffer_size is
+ * defined.
+ *
+ * We are called in the beginning of snd_pcm_hw_params in
+ * sound/core/pcm_native.c, we cannot override runtime-values as they
+ * are updated from hw_params.
+ */
+static int snd_avb_pcm_hw_params(struct snd_pcm_substream *substream,
+				struct snd_pcm_hw_params *hw_params)
+{
+	struct avb_chip *avb_chip = snd_pcm_substream_chip(substream);
+	unsigned int bsize = params_buffer_bytes(hw_params);
+	int ret = 0;
+
+	/* We need this reference for the refill callback so that we can
+	 * call snd_pcm_period_elapsed();
+	 */
+	avb_chip->substream = substream;
+	ret = tsn_set_buffer_size(avb_chip->link, bsize);
+	if (ret < 0) {
+		pr_err("%s: could not set buffer_size (alsa requested too large? (%d)\n",
+			__func__, ret);
+		goto out;
+	}
+
+	avb_chip->num_10ms_series = 0;
+	pr_info("%s: successfully set hw-params\n", __func__);
+out:
+	return ret;
+}
+
+static int snd_avb_pcm_hw_free(struct snd_pcm_substream *substream)
+{
+	struct avb_chip *avb_chip = snd_pcm_substream_chip(substream);
+
+	if (!avb_chip || !avb_chip->link)
+		return -EINVAL;
+	tsn_clear_buffer_size(avb_chip->link);
+	pr_info("%s: something happened\n", __func__);
+	avb_chip->substream = NULL;
+	return 0;
+}
+
+static int snd_avb_pcm_prepare(struct snd_pcm_substream *substream)
+{
+	/* verify that samplerate, freq and size is what we have set in
+	 * the link.
+	 */
+
+	return 0;
+}
+
+/*
+ * When the PCM stream is started, stopped, paused etc.
+ *
+ * Atomic function (some lock is being held by PCM layer)
+ */
+static int snd_avb_pcm_trigger(struct snd_pcm_substream *substream,
+			       int cmd)
+{
+	struct avb_chip *avb_chip = snd_pcm_substream_chip(substream);
+
+	switch (cmd) {
+	case SNDRV_PCM_TRIGGER_START:
+	case SNDRV_PCM_TRIGGER_RESUME:
+		/* pr_err("%s: starting for some reason\n", __func__); */
+		tsn_lb_enable(avb_chip->link);
+		break;
+	case SNDRV_PCM_TRIGGER_STOP:
+	case SNDRV_PCM_TRIGGER_SUSPEND:
+		/* memset buffer to 0 */
+		/* pr_err("%s: stopping for some reason\n", __func__); */
+		tsn_lb_disable(avb_chip->link);
+		break;
+	default:
+		pr_info("%s: cmd: %d (return -EINVAL)\n", __func__, cmd);
+		return -EINVAL;
+	}
+	return 0;
+}
+
+/*
+ * current hw-position in the buffer, in frames from 0 to buffer_size -1
+ *
+ * Need to know where the hw-pointer is and how this corresponds to the
+ * underlying TSN-buffer setup
+ *
+ * Atomic function (some lock is being held by PCM layer)
+ *
+ */
+static snd_pcm_uframes_t snd_avb_pcm_pointer(struct snd_pcm_substream *substream)
+{
+	struct avb_chip *avb_chip = snd_pcm_substream_chip(substream);
+	struct tsn_link *link = avb_chip->link;
+	snd_pcm_uframes_t pointer;
+
+	if (link->estype_talker)
+		pointer = bytes_to_frames(substream->runtime,
+					  link->tail - link->buffer);
+	else
+		pointer = bytes_to_frames(substream->runtime,
+					  link->head - link->buffer);
+	return pointer;
+}
+
+static struct snd_pcm_ops snd_avb_playback_ops = {
+	.open      = snd_avb_playback_open,
+	.close     = snd_avb_playback_close,
+	.copy	   = snd_avb_playback_copy,
+	.silence   = snd_avb_silence,
+	.ioctl     = snd_pcm_lib_ioctl,
+	.hw_params = snd_avb_pcm_hw_params,
+	.hw_free   = snd_avb_pcm_hw_free,
+	.prepare   = snd_avb_pcm_prepare,
+	.trigger   = snd_avb_pcm_trigger,
+	.pointer   = snd_avb_pcm_pointer,
+};
+
+static struct snd_pcm_ops snd_avb_capture_ops = {
+	.open      = snd_avb_capture_open,
+	.close     = snd_avb_capture_close,
+	.copy	   = snd_avb_capture_copy,
+	.silence   = snd_avb_silence,
+	.ioctl     = snd_pcm_lib_ioctl,
+	.hw_params = snd_avb_pcm_hw_params,
+	.hw_free   = snd_avb_pcm_hw_free,
+	.prepare   = snd_avb_pcm_prepare,
+	.trigger   = snd_avb_pcm_trigger,
+	.pointer   = snd_avb_pcm_pointer,
+};
+
+/*
+ * Callback for tsn_core for moving data into the buffer.
+ *
+ * This should be a wrapper (replace it with) the refill-functionality ALSA use.
+ */
+static size_t snd_avb_refill(struct tsn_link *link)
+{
+	struct avb_chip *avb_chip = link->media_chip;
+
+	if (avb_chip && avb_chip->substream) {
+		snd_pcm_period_elapsed(avb_chip->substream);
+		return 0;
+	}
+	return -EINVAL;
+}
+
+static size_t snd_avb_drain(struct tsn_link *link)
+{
+	struct avb_chip *avb_chip = link->media_chip;
+
+	if (avb_chip && avb_chip->substream) {
+		snd_pcm_period_elapsed(avb_chip->substream);
+		return 0;
+	}
+	return -EINVAL;
+}
+
+static size_t snd_avb_hdr_size(struct tsn_link *link)
+{
+	/* return the size of the iec61883-6 audio header */
+	return _iec61883_hdr_len();
+}
+
+static size_t snd_avb_copy_size(struct tsn_link *link)
+{
+	struct avb_chip *chip = link->media_chip;
+	/* use values in avb_chip, not link */
+	size_t framesize = (chip->sample_size >> 3) * chip->channels;
+	size_t numframes = 0;
+
+	if (!chip->sample_freq)
+		return link->max_payload_size;
+
+	/* size of each frame (samples per frame, sample-size && class)
+	 * sample_size: 16 -> 2
+	 * spframe :    12 (class b)
+	 * channels:     2
+	 *
+	 * framesize:  2*12*2 -> 48
+	 */
+
+	switch (chip->sample_freq) {
+	case 44100:
+		/*
+		 * Class B: 40 frames, first 12 bytes, next 39 should be 11
+		 */
+		if (!link->class_a) {
+			numframes = (chip->num_10ms_series ? 11 : 12);
+			chip->num_10ms_series++;
+			if (chip->num_10ms_series > 39)
+				chip->num_10ms_series = 0;
+		} else {
+			/* Class A slightly more involved
+			 * Need 41 6 bytes and 39 5 bytes
+			 *
+			 * If 0th is set to 6, remaining odd idx should
+			 * be 6, even (except 0th) to be 6
+			 */
+			numframes = 5;
+			if (!chip->num_10ms_series ||
+			    (chip->num_10ms_series % 0x2))
+				numframes++;
+			chip->num_10ms_series++;
+			if (chip->num_10ms_series > 79)
+				chip->num_10ms_series = 0;
+		}
+		break;
+	case 48000:
+		numframes = (link->class_a ? 6 : 12);
+		break;
+	default:
+		pr_err("Unsupported sample_freq (%d), disabling link\n",
+		       chip->sample_freq);
+		tsn_lb_disable(link);
+		return -EINVAL;
+	}
+	return numframes * framesize;
+}
+
+static void snd_avb_assemble_iidc(struct tsn_link *link,
+				  struct avtpdu_header *header, size_t bytes)
+{
+	_iec61883_hdr_assemble(header, bytes);
+}
+
+static int snd_avb_validate_iidc(struct tsn_link *link,
+				 struct avtpdu_header *header)
+{
+	return _iec61883_hdr_verify(header);
+}
+
+static void *snd_avb_get_payload_data(struct tsn_link *link,
+				      struct avtpdu_header *header)
+{
+	return _iec61883_payload(header);
+}
+
+static int snd_avb_new_pcm(struct avb_chip *avb_chip, int device)
+{
+	struct snd_pcm *pcm;
+	int err;
+
+	err = snd_pcm_new(avb_chip->card, "AVB PCM", device, 1, 1, &pcm);
+	if (err < 0)
+		return err;
+	pcm->private_data = avb_chip;
+	strcpy(pcm->name, "AVB PCM");
+	avb_chip->pcm = pcm;
+
+	/* only playback at the moment, once we implement capture, we
+	 * need to grab the Talker/Listener from TSN link
+	 */
+	snd_pcm_set_ops(pcm, SNDRV_PCM_STREAM_PLAYBACK, &snd_avb_playback_ops);
+	snd_pcm_set_ops(pcm, SNDRV_PCM_STREAM_CAPTURE,  &snd_avb_capture_ops);
+
+	return 0;
+
+}
+static int snd_avb_probe(struct platform_device *devptr)
+{
+	int err;
+	struct snd_card *card;
+	struct avb_chip *avb_chip;
+
+	pr_info("%s: starting\n", __func__);
+
+	/*
+	 * older kernel use snd_card_create. This is handled by
+	 * tsn_compat.h in an attempt to make it easier to backport to
+	 * older kernels.
+	 */
+	err = snd_card_new(&devptr->dev, 1, "avb", THIS_MODULE,
+			   sizeof(struct avb_chip), &card);
+	if (err < 0) {
+		pr_err("%s: trouble creating new card -> %d\n",
+			__func__, err);
+		return err;
+	}
+	avb_chip = card->private_data;
+	avb_chip->card = card;
+
+
+	/* create PCM device*/
+	err = snd_avb_new_pcm(avb_chip, 0);
+	if (err < 0) {
+		pr_err("%s: could not create new PCM device\n", __func__);
+		goto err_out;
+	}
+
+	/* register card */
+	pr_info("%s: ready to register card\n", __func__);
+	strcpy(card->driver, "Avb");
+	strcpy(card->shortname, "Avb");
+	sprintf(card->longname, "Avb %i", devptr->id + 1);
+	err = snd_card_register(card);
+	if (err < 0) {
+		pr_err("%s: Could not register card -> %d\n",
+			__func__, err);
+		snd_card_free(card);
+		return err;
+	}
+
+	if (err == 0) {
+		platform_set_drvdata(devptr, card);
+		pr_info("%s: Successfully initialized %s\n",
+			__func__, card->shortname);
+		return 0;
+	}
+err_out:
+	snd_card_free(card);
+	return err;
+}
+
+/*
+ * We are here as a result from being removed via
+ * tsn_link->shim_ops->media_close, which is snd_avb_close()
+ */
+static int snd_avb_remove(struct platform_device *devptr)
+{
+	struct snd_card *card     = platform_get_drvdata(devptr);
+	struct avb_chip *avb_chip = card->private_data;
+
+	/* Make sure link holds no ref to this now dead card */
+	if (avb_chip && avb_chip->link) {
+		avb_chip->link->media_chip = NULL;
+		avb_chip->link = NULL;
+	}
+
+	/* call into link->ops->media_close() ? */
+	snd_card_free(card);
+	return 0;
+}
+
+static struct platform_driver snd_avb_driver = {
+	.probe  = snd_avb_probe,
+	.remove = snd_avb_remove,
+	.driver = {
+		.name = "snd_avb",
+		.pm   = NULL,	/* don't care about Power Management */
+	},
+};
+
+static int snd_avb_close(struct tsn_link *link)
+{
+	struct avb_chip *avb_chip = link->media_chip;
+
+	if (!link->media_chip)
+		return 0;
+
+	pr_info("%s: Removing device\n", __func__);
+
+	platform_device_unregister(avb_chip->device);
+	/* platform unregister will call into snd_avb_remove */
+	platform_driver_unregister(&snd_avb_driver);
+
+	/* update link to remove pointer to now invalid memory */
+	link->media_chip = NULL;
+	return 0;
+}
+
+static int snd_avb_new(struct tsn_link *link)
+{
+	struct avb_chip *avb_chip;
+	struct snd_card *card;
+	struct platform_device *device;
+	int err;
+
+	err = platform_driver_register(&snd_avb_driver);
+	if (err < 0) {
+		pr_info("%s: trouble registering driver %d, unreg. partial driver and abort.\n",
+			__func__, err);
+		return err;
+	}
+
+	/*
+	 * We only register a single card for now, look to
+	 * /sys/devices/platform/snd_avb.0 for content.
+	 *
+	 * Probe will be triggered if name is same as .name in platform_driver
+	 */
+	device = platform_device_register_simple("snd_avb", 0, NULL, 0);
+	if (IS_ERR(device)) {
+		pr_info("%s: ERROR registering simple platform-device\n",
+			__func__);
+		platform_driver_unregister(&snd_avb_driver);
+		return -ENODEV;
+	}
+
+	/* store data in driver so we can access it in .probe */
+	card = platform_get_drvdata(device);
+	if (card == NULL) {
+		pr_info("%s: Did not get anything from platform_get_drvdata()\n",
+			__func__);
+		platform_device_unregister(device);
+		return -ENODEV;
+	}
+	avb_chip = card->private_data;
+	avb_chip->device = device;
+	avb_chip->link = link;
+
+	link->media_chip = avb_chip;
+
+	return 0;
+}
+
+static struct tsn_shim_ops shim_ops = {
+	.shim_name	 = "alsa",
+	.probe		 = snd_avb_new,
+	.buffer_refill   = snd_avb_refill,
+	.buffer_drain    = snd_avb_drain,
+	.media_close     = snd_avb_close,
+	.hdr_size        = snd_avb_hdr_size,
+	.copy_size       = snd_avb_copy_size,
+	.assemble_header = snd_avb_assemble_iidc,
+	.validate_header = snd_avb_validate_iidc,
+	.get_payload_data = snd_avb_get_payload_data,
+};
+
+static int __init avb_alsa_init(void)
+{
+	if (tsn_shim_register_ops(&shim_ops)) {
+		pr_err("Could not register ALSA-shim with TSN\n");
+		return -EINVAL;
+	}
+	pr_info("AVB ALSA added OK\n");
+	return 0;
+}
+
+static void __exit avb_alsa_exit(void)
+{
+	tsn_shim_deregister_ops(&shim_ops);
+}
+
+module_init(avb_alsa_init);
+module_exit(avb_alsa_exit);
+MODULE_AUTHOR("Henrik Austad");
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("TSN ALSA shim driver");
diff --git a/drivers/media/avb/tsn_iec61883.h b/drivers/media/avb/tsn_iec61883.h
new file mode 100644
index 0000000..bf26138
--- /dev/null
+++ b/drivers/media/avb/tsn_iec61883.h
@@ -0,0 +1,124 @@
+#ifndef TSN_IEC61883_H
+#define TSN_IEC61883_H
+#include <linux/tsn.h>
+
+/*
+ * psh:
+ *  tag:2
+ *  channel:6
+ *  tcode:4
+ *  sy:4
+ * See IEEE 1722.1 :: 6.2 for details
+ */
+struct iec61883_tag {
+	u8 tag:2;
+	u8 channel:6;
+	u8 tcode:4;
+	u8 sy:4;
+} __packed;
+
+struct iec61883_audio_header {
+	u8 sid:6;
+	u8 cip_1:2;
+
+	u8 dbs:8;
+
+	u8 rsv:2;		/* reserved */
+	u8 sph:1;
+	u8 qpc:3;
+	u8 fn:2;
+
+	u8 dbc;
+
+	u8 fmt:6;
+	u8 cip_2:2;
+	u8 fdf;
+	u16 syt;
+	u8 payload[0];
+} __packed;
+
+static inline size_t _iec61883_hdr_len(void)
+{
+	return sizeof(struct iec61883_audio_header);
+}
+
+static inline int _iec61883_hdr_verify(struct avtpdu_header *hdr)
+{
+	struct iec61883_audio_header *dh;
+	struct iec61883_tag *psh;
+
+	if (hdr->subtype != AVTP_61883_IIDC)
+		return -EINVAL;
+	dh  = (struct iec61883_audio_header *)&hdr->data;
+	psh = (struct iec61883_tag *)&hdr->psh;
+
+	/* Verify 61883 header */
+	if (psh->tag != 1 || psh->channel != 31 ||
+		psh->tcode != 0xA || psh->sy != 0)
+		return -EINVAL;
+
+	/* check flags that should be static from frame to frame */
+	if (dh->cip_1 != 0 || dh->sid != 0x3f || dh->qpc != 0 || dh->fn != 0 ||
+		dh->sph != 0 || dh->cip_2 != 2)
+		return -EINVAL;
+
+	if (dh->dbs != ntohs(hdr->sd_len)*2 || dh->dbc != hdr->seqnr)
+		return -EINVAL;
+
+	return 0;
+}
+
+static inline void _iec61883_hdr_assemble(struct avtpdu_header *hdr,
+					  size_t bytes)
+{
+	struct iec61883_tag *psh;
+	struct iec61883_audio_header *dh;
+
+	if (bytes > 0x7f)
+		pr_warn("%s: hdr->dbs will overflow, malformed frame will be the result\n",
+			__func__);
+
+
+	hdr->subtype = AVTP_61883_IIDC;
+
+	/* IIDC 61883 header */
+	psh = (struct iec61883_tag *)&hdr->psh;
+	psh->tag = 1;
+	psh->channel = 31;      /* 0x1f */
+	psh->tcode = 0xA;
+	psh->sy = 0;
+
+	dh = (struct iec61883_audio_header *)&hdr->data;
+	dh->cip_1 = 0;
+	dh->sid = 63;           /* 0x3f */
+	dh->dbs = (u8)(bytes*2); /* number of quadlets of data in AVTPDU */
+	dh->qpc = 0;
+	dh->fn = 0;
+	dh->sph = 0;
+	dh->dbc = hdr->seqnr;
+	dh->cip_2 = 2;
+
+	/*
+	 * FMT (Format ID): same as specified in iec 61883-1:2003
+	 *
+	 * For IEC 61883-6, it shall be 0x10 (16) to define Audio and
+	 * Music data
+	 */
+	dh->fmt = 0x10;
+
+	/* FIXME: find value
+	 * Could be sampling-freq, but 8 bits give 0 - 65kHz sampling.
+	 */
+	dh->fdf = 0;
+
+	dh->syt = 0xFFFF;
+}
+
+static inline void *_iec61883_payload(struct avtpdu_header *hdr)
+{
+	struct iec61883_audio_header *dh = (struct iec61883_audio_header *)&hdr->data;
+	/* TODO: add some basic checks before returning payload ? */
+	return &dh->payload;
+}
+
+#endif	/* TSN_IEC61883_H */
-- 
2.7.4
