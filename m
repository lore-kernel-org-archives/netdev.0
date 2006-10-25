From: Hong Liu <hong.liu@intel.com>
Subject: about 802.11i IBSS support
Date: Wed, 25 Oct 2006 16:54:41 +0800
Message-ID: <1161766481.8668.38.camel@devlinux-hong>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:44292 "EHLO mga02.intel.com")
	by vger.kernel.org with ESMTP id S1423135AbWJYJBf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2006 05:01:35 -0400
To: Jouni Malinen <jkm@devicescape.com>, Jiri Benc <jbenc@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
I am reading the 802.11i IBSS spec and
trying to find if it is OK to add patches to d80211 to support this feature.

For 802.11i IBSS to work, each STA assumes two roles: supplicant + authenticator.
Usually in BSS network, authenticator is in AP.
The problem is the distribution of group keys.
The group key is used for one-to-many communication.
In BSS, the one is the AP, so the AP is responsible for the distribution of the group key.
In IBSS, every STA has its own group key, used to broadcast data to other STAs.

When a STA (say S1) joins in an IBSS network with N STAs,
it must negotiate keys with all N STAs.
The process for negotiation with one STA is as follows:
1. S1 init a 4-way handshake with one STA (say S2),
   to derive the pairwise key between them and then S1 sends its group key to S2,
   let S2 can decrypt s1's broadcast data.
2. S2 init the second 4-way handshake with S1, the main purpose for this 4-way handshake
   is for S2 to send its group key to S1, although this will also derive a second pairwise key.
3. Because in an IBSS there are two 4-Way Handshakes between 
   any two STA Supplicants and Authenticators, the pairwise key used between any two STAs
   is from the 4-Way Handshake initiated by the STA Authenticator with the higher MAC address.
So any STA in an IBSS network with N STAs must keep 2N-1 keys (N-1 for pairwise key and N for group key).

We need the following parts to make 802.11i IBSS work:

1. for the d80211 part: I don't think there will be much efforts.
   We may add a group key to each sta_info for decrypting multicast data from that STA.
   And in RX path, we need to add code to select the correct group key for decryption.
   And also we need to store our own group key used to send multicast data to others.

   It should not be difficult because the infrastructures are all there in the dscape stack.

2. wpa_supplicant: this is the big part, we need to implement the authenticator
   in it. Not sure how much efforts needed?

Thanks,
Hong
