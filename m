From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 03/39] wimax: constants and definitions to interact with user space
Date: Wed, 26 Nov 2008 14:40:22 -0800
Message-ID: <999a8be21ed5a6c6d5960789783b38bf51dfd3c3.1227691434.git.inaky@linux.intel.com>
References: <cover.1227691434.git.inaky@linux.intel.com>
Cc: wimax@linuxwimax.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga10.intel.com ([192.55.52.92]:43324 "EHLO
	fmsmga102.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752189AbYKZWlM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 17:41:12 -0500
In-Reply-To: <cover.1227691434.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This file defines the user/kernel API protocol through generic
netlink.

User space can copy it verbatim and use it.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 include/linux/wimax.h |  235 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 235 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/wimax.h

diff --git a/include/linux/wimax.h b/include/linux/wimax.h
new file mode 100644
index 0000000..f9d6a17
--- /dev/null
+++ b/include/linux/wimax.h
@@ -0,0 +1,235 @@
+/*
+ * Linux WiMax
+ * API for user space
+ *
+ *
+ * Copyright (C) 2007 Intel Corporation <linux-wimax@intel.com>
+ * Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version
+ * 2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA.
+ *
+ *
+ * This file declares the user/kernel protocol that is spoken over
+ * Generic Netlink, as well as any type declaration that is to be used
+ * by kernel and user space.
+ *
+ * It is intended for user space to clone it verbatim to use it as a
+ * primary reference for definitions.
+ *
+ * Stuff intended for kernel usage as well as full protocol and stack
+ * documentation is rooted in include/net/wimax.h.
+ */
+
+#ifndef __LINUX__WIMAX_H__
+#define __LINUX__WIMAX_H__
+
+#include <linux/types.h>
+
+enum {
+	/**
+	 * Version of the interface (unsigned decimal, MMm, max 25.5)
+	 * M - Major: change if removing or modifying an existing call.
+	 * m - minor: change when adding a new call
+	 */
+	WIMAX_GNL_VERSION = 00,
+	/* Generic NetLink attributes */
+	WIMAX_GNL_ATTR_INVALID = 0x00,
+	WIMAX_GNL_ATTR_MAX = 5,
+};
+
+
+/*
+ * Generic NetLink operations
+ *
+ * Most of these map to an API call; _OP_ stands for operation, _RP_
+ * for reply and _RE_ for report (aka: signal).
+ */
+enum {
+	WIMAX_GNL_OP_MSG_FROM_USER,	/* User to kernel message */
+	WIMAX_GNL_OP_MSG_TO_USER,	/* Kernel to user message */
+	WIMAX_GNL_OP_OPEN,	/* Open a handle to a wimax device */
+	WIMAX_GNL_OP_UNUSED,	/* Unused */
+	WIMAX_GNL_OP_RFKILL,	/* Run wimax_rfkill() */
+	WIMAX_GNL_RP_IFINFO,	/* Reply to OPEN: Interface info */
+	WIMAX_GNL_RP_RESULT,	/* Reply: result of operation */
+	WIMAX_GNL_OP_RESET,	/* Run wimax_rfkill() */
+	WIMAX_GNL_RE_STATE_CHANGE,	/* Report: status change */
+	WIMAX_GNL_OP_MAX,
+};
+
+
+/* Message from user / to user */
+enum {
+	WIMAX_GNL_MSG_DATA = 1,
+};
+
+
+/*
+ * wimax_rfkill()
+ *
+ * The state of the radio (ON/OFF) is mapped to the rfkill subsystem's
+ * switch state (DISABLED/ENABLED).
+ */
+enum wimax_rf_state {
+	WIMAX_RF_OFF = 0,	/* Radio is off, rfkill on/enabled */
+	WIMAX_RF_ON = 1,	/* Radio is on, rfkill off/disabled */
+	WIMAX_RF_QUERY = 2,
+};
+
+/* Attributes */
+enum {
+	WIMAX_GNL_RFKILL_STATE = 1,
+};
+
+
+/*
+ * wimax_open()
+ *
+ * Attributes for the interface-info reply
+ */
+enum {
+	WIMAX_GNL_IFINFO_MC_GROUPS = 1,
+	WIMAX_GNL_IFINFO_MC_GROUP,
+	WIMAX_GNL_IFINFO_MC_NAME,
+	WIMAX_GNL_IFINFO_MC_ID,
+	WIMAX_GNL_IFINFO_MAX,		/* Used by user space */
+};
+
+
+/*
+ * Attributes for the result-of-operation
+ */
+enum {
+	WIMAX_GNL_RESULT_CODE = 1,
+};
+
+
+/*
+ * Attributes for the Report State Change
+ *
+ * For now we just have the old and new states; new attributes might
+ * be added later on.
+ */
+enum {
+	WIMAX_GNL_STCH_STATE_OLD = 1,
+	WIMAX_GNL_STCH_STATE_NEW,
+};
+
+
+/**
+ * enum wimax_st - The different states of a WiMAX device
+ * @__WIMAX_ST_NULL: The device structure has been allocated and zeroed,
+ *     but still wimax_dev_add() hasn't been called. There is no state.
+ *
+ * @WIMAX_ST_DOWN: The device has been registered with the WiMAX and
+ *     networking stacks, but it is not initialized (normally that is
+ *     done with 'ifconfig DEV up' [or equivalent], which can upload
+ *     firmware and enable communications with the device).
+ *     In this state, the device is powered down and using as less
+ *     power as possible.
+ *     This state is the default after a call to wimax_dev_add(). It
+ *     is ok to have drivers move directly to %WIMAX_ST_UNINITIALIZED
+ *     or %WIMAX_ST_RADIO_OFF in _probe() after the call to
+ *     wimax_dev_add().
+ *     It is recommended that the driver leaves this state when
+ *     calling 'ifconfig DEV up' and enters it back on 'ifconfig DEV
+ *     down'.
+ *
+ * @__WIMAX_ST_QUIESCING: The device is being torn down, so no API
+ *     operations are allowed to proceed except the ones needed to
+ *     complete the device clean up process.
+ *
+ * @WIMAX_ST_UNINITIALIZED: [optional] Communication with the device
+ *     is setup, but the device still requires some configuration
+ *     before being operational.
+ *     Some WiMAX API calls might work.
+ *
+ * @WIMAX_ST_RADIO_OFF: The device is fully up; radio is off (wether
+ *     by hardware or software switches).
+ *     It is recommended to always leave the device in this state
+ *     after initialization.
+ *
+ * @WIMAX_ST_READY: The device is fully up and radio is on.
+ *
+ * @WIMAX_ST_SCANNING: [optional] The device has been instructed to
+ *     scan. In this state, the device cannot be actively connected to
+ *     a network.
+ *
+ * @WIMAX_ST_CONNECTING: The device is connecting to a network. This
+ *     state exists because in some devices, the connect process can
+ *     include a number of negotiations between user space, kernel
+ *     space and the device. User space needs to know what the device
+ *     is doing. If the connect sequence in a device is atomic and
+ *     fast, the device can transition directly to CONNECTED
+ *
+ * @WIMAX_ST_CONNECTED: The device is connected to a network.
+ *
+ * @__WIMAX_ST_INVALID: This is an invalid state used to mark the
+ *     maximum numeric value of states.
+ *
+ * Description:
+ *
+ * Transitions from one state to another one are atomic and can only
+ * be caused in kernel space with wimax_state_change(). To read the
+ * state, use wimax_state_get().
+ *
+ * States starting with __ are internal and shall not be used or
+ * referred to by drivers. They look ugly, but that's the point -- if
+ * any use is made non-internal to the stack, it is easier to catch on
+ * review.
+ *
+ * All API operations [with well defined exceptions] will take the
+ * device mutex before starting and then check the state. If the state
+ * is %__WIMAX_ST_NULL, %WIMAX_ST_DOWN, %WIMAX_ST_UNINITIALIZED or
+ * %__WIMAX_ST_QUIESCING, it will drop the lock and quit with
+ * -%EINVAL, -%ENOMEDIUM, -%ENOTCONN or -%ESHUTDOWN.
+ *
+ * The order of the definitions is important, so we can do numerical
+ * comparisons (eg: < %WIMAX_ST_RADIO_OFF means the device is not ready
+ * to operate).
+ */
+/*
+ * The allowed state transitions are described in the table below
+ * (states in rows can go to states in columns where there is an X):
+ *
+ *                                  UNINI   RADIO READY SCAN CONNEC CONNEC
+ *             NULL DOWN QUIESCING TIALIZED  OFF        NING  TING   TED
+ * NULL         -    x
+ * DOWN              -      x        x       x
+ * QUIESCING         x      -
+ * UNINITIALIZED            x        -       x
+ * RADIO_OFF                x                -     x
+ * READY                    x                x     -     x     x      x
+ * SCANNING                 x                x     x     -     x      x
+ * CONNECTING               x                x     x     x     -      x
+ * CONNECTED                x                x     x                  -
+ *
+ * This table not available in kernel-doc because the formatting messes it up.
+ */
+ enum wimax_st {
+	__WIMAX_ST_NULL = 0,
+	WIMAX_ST_DOWN,
+	__WIMAX_ST_QUIESCING,
+	WIMAX_ST_UNINITIALIZED,
+	WIMAX_ST_RADIO_OFF,
+	WIMAX_ST_READY,
+	WIMAX_ST_SCANNING,
+	WIMAX_ST_CONNECTING,
+	WIMAX_ST_CONNECTED,
+	__WIMAX_ST_INVALID			/* Always keep last */
+};
+
+
+#endif /* #ifndef __LINUX__WIMAX_H__ */
-- 
1.5.6.5

