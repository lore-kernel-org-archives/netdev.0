From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC 25/28] Documentation: DSA: Describe how probe of DSA and switches work.
Date: Wed, 23 Dec 2015 13:56:39 +0100
Message-ID: <1450875402-20740-26-git-send-email-andrew@lunn.ch>
References: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>, narmstrong@baylibre.com,
	vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48772 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757195AbbLWM63 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Dec 2015 07:58:29 -0500
In-Reply-To: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the introduction of switches as linux devices and the use of the
component framework, probing has become more complex. Add some
documentation.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 Documentation/networking/dsa/dsa.txt | 48 ++++++++++++++++++++++++++++++++++++
 1 file changed, 48 insertions(+)

diff --git a/Documentation/networking/dsa/dsa.txt b/Documentation/networking/dsa/dsa.txt
index aa9c1f9313cd..376afa135a81 100644
--- a/Documentation/networking/dsa/dsa.txt
+++ b/Documentation/networking/dsa/dsa.txt
@@ -398,6 +398,54 @@ Switch configuration
   on the management interface and "hardcode"/"force" this MAC address for the
   CPU/management interface as an optimization
 
+Call flow
+---------
+
+With the ability for switch devices to be true linux devices, the call
+flow is somewhat complex. The component framework is used to link the
+dsa framework as the master, with switch devices, as slaves.
+
+A switch device should add itself as a component in its probe
+function.
+
+The DSA framework can either be configured using a platform_data
+structure or from the device tree. If device tree is being used, the
+dsa framework probe function will allocate a platform_data structure,
+and populate it using the device tree, via the dsa_of_probe()
+function.  Within the DSA device tree, switch devices are represented
+by a phandle to the switch device. These phandles are saved into the
+platform data so that when switch slaves register themselves, they can
+be correctly positioned in the DSA cluster.
+
+The DSA probe function then creates a dsa_switch_tree structure which
+is the overarching structure representing a switch cluster. The probe
+function then looks in the platform data for the phandles to slave
+devices, and adds a component match based on the phandle. The
+component master is then created. This causes the component framework
+to link slaves to the master.
+
+If all the slave switch can be found, the masters bind function is
+called, dsa_bind(). This in tern causes the switch slaves bind
+function to be called.
+
+The switches bind function allocated memory for its own private use,
+and for a dsa_switch structure, which represents one switch in a DSA
+cluster. The switch then registers with the DSA framework using
+dsa_switch_register().
+
+dsa_switch_register() looks in the platform data and finds the
+position within the cluster for the switch which is registering. The
+switches dsa_switch structure is then attached to the dsa_switch_tree
+structure in the correct place.
+
+Once all slave switches have registered, dsa_setup_dst() is used to
+complete the construction of the dsa_switch_tree structure. This
+starts by setting up switches which are not slave devices. The MDIO
+address of the switch is passed to each switch driver to see if it can
+drive the switch. If it can, a dsa_switch structure is allocated to
+represent the switch and linked into the dsa_switch_tree at the
+correct location.
+
 PHY devices and link management
 -------------------------------
 
-- 
2.6.3
