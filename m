From: Tsutomu Fujii <t-fujii@nb.jp.nec.com>
Subject: Bonding in active-backup mode with arp monitoring on Xen
Date: Mon, 29 Oct 2007 10:16:55 +0900
Message-ID: <47253487.3010909@nb.jp.nec.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030706080809070300090504"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO202.gate.nec.co.jp ([202.32.8.206]:57058 "EHLO
	tyo202.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752247AbXJ2BRA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Oct 2007 21:17:00 -0400
Received: from mailgate3.nec.co.jp (mailgate53.nec.co.jp [10.7.69.161])
	by tyo202.gate.nec.co.jp (8.13.8/8.13.4) with ESMTP id l9T1GwK8020112
	for <netdev@vger.kernel.org>; Mon, 29 Oct 2007 10:16:58 +0900 (JST)
Received: (from root@localhost) by mailgate3.nec.co.jp (8.11.7/3.7W-MAILGATE-NEC)
	id l9T1Gvx00974 for netdev@vger.kernel.org; Mon, 29 Oct 2007 10:16:57 +0900 (JST)
Received: from shoin.jp.nec.com (shoin.jp.nec.com [10.26.220.3]) by mailsv3.nec.co.jp (8.11.7/3.7W-MAILSV4-NEC) with ESMTP
	id l9T1GvB00211 for <netdev@vger.kernel.org>; Mon, 29 Oct 2007 10:16:57 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030706080809070300090504
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit

Hi.

I was trying to use bonding from a guest OS on xen in active-backup
mode with arp monitoring, but the virtual server can't communicate to
the peer server via bonding interface.

The network structure is the following.

+-------------------------------+
|        virtual I/F(eth0)      | <- have IP address.
+-------------------------------+
|      virtual bridge(xenbr0)   |
+-------------------------------+
|         bonding(bond0)        | <- don't have IP address
+--------------+-+--------------+
|phy I/F(peth0)| |phy I/F(peth1)|
+--------------+ +--------------+

The attached file describes how I configured the network.

In this case, when I run 'cat /proc/net/bonding/bond0', 'MII Status'
is shown as down.

This behavior only occurs in active-backup mode with arp monitoring.
It does not happen in active-backup mode with mii monitoring nor other
mode that can use arp monitoring.

>From the output of tcpdump, it seems that arp packet isn't transmitted.
This problem is caused because bond_activebackup_arp_mon(), which is the
function that sends arp packet in active-backup mode, checks whether
bonding master interface has an IP address(bond_has_ip()), before arp
packets are transmitted using bond_arp_send_all().
In the above setting, bonding master interface don't have IP address.

How about removing bond_has_ip() from the condition for calling
bond_arp_send_all() to use bonding with xen?
When I removed bond_has_ip(), the resulting kernel worked fine and
active-backup mode works with arp monitoring.

I confirmed this behavior in RHEL5(2.6.18-44.el5xen). And I confirmed
that the upstream kernel(2.6.23) also has the same condition before
calling bond_arp_send_all().

Thanks.

---
Tsutomu Fujii



--------------030706080809070300090504
Content-Type: text/plain;
 name="set_bonding.txt"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="set_bonding.txt"

U2V0dGluZyBwcm9jZWR1cmUgb2YgYm9uZGluZy4KCjEpIE1ha2Ugb3IgbW9kaWZ5IHRoZSBm
b2xsb3dpbmcgY29uZmlnIGZpbGUgb24gZG9tMC4KICAgLSAvZXRjL3N5c2NvbmZpZy9uZXR3
b3JrLXNjcmlwdHMvaWZjZmctYm9uZDAKICAgICBUWVBFPUJvbmRpbmcKICAgICBERVZJQ0U9
Ym9uZDAKICAgICBCT09UUFJPVE89bm9uZQogICAgIE9OQk9PVD1ubwoKICAgLSAvZXRjL3N5
c2NvbmZpZy9uZXR3b3JrLXNjcmlwdHMvaWZjZmctZXRoMQogICAgIERFVklDRT1ldGgxCiAg
ICAgQk9PVFBST1RPPW5vbmUKICAgICBPTkJPT1Q9bm8KCiAgIC0gL2V0Yy9zeXNjb25maWcv
bmV0d29yay1zY3JpcHRzL2lmY2ZnLWV0aDIKICAgICBERVZJQ0U9ZXRoMgogICAgIEJPT1RQ
Uk9UTz1ub25lCiAgICAgT05CT09UPW5vCgogICAtIC9ldGMvbW9kcHJvYmUuY29uZiAoQWRk
IHRvIGZvbGxvd2luZyB0d28gbGluZXMuKQogICAgIGFsaWFzIGJvbmQwIGJvbmRpbmcKICAg
ICBvcHRpb25zIGJvbmRpbmcgbW9kZT0xIGFycF9pbnRlcnZhbD0xMDAgYXJwX2lwX3Rhcmdl
dD0xOTIuMTY4LjAuMjU0CgoyKSBSdW4gdGhlIGZvbGxvd2luZyBjb21tYW5kIG9uIGRvbTAu
CiAgICMgYnJjdGwgYWRkYnIgeGVuYnIwCiAgICMgaXAgbGluayBzZXQgeGVuYnIwIGFycCBv
ZmYKICAgIyBpcCBsaW5rIHNldCB4ZW5icjAgbXVsdGljYXN0IG9mZgoKICAgIyBpcCBsaW5r
IHNldCBldGgwIG5hbWUgcGV0aDAKICAgIyBpcCBsaW5rIHNldCBldGgxIG5hbWUgcGV0aDEK
ICAgIyBpcCBsaW5rIHNldCB2ZXRoMCBuYW1lIGV0aDAKICAgIyBpcCBsaW5rIHNldCB2ZXRo
MSBuYW1lIGV0aDEKCiAgICMgaWZ1cCBib25kMAogICAjIGlmZW5zbGF2ZSBib25kMCBwZXRo
MCBwZXRoMQogICAjIGlmZG93biBib25kMAoKICAgIyBpcCBsaW5rIHNldCBib25kMCBkb3du
CiAgICMgaXAgbGluayBzZXQgYm9uZDAgYXJwIG9mZgogICAjIGlwIGxpbmsgc2V0IGJvbmQw
IG11bHRpY2FzdCBvZmYKICAgIyBpcCBsaW5rIHNldCBib25kMCBhZGRyIGZlOmZmOmZmOmZm
OmZmOmZmCgogICAjIGlwIGxpbmsgc2V0IHZpZjAuMCBkb3duCiAgICMgaXAgbGluayBzZXQg
dmlmMC4wIGFycCBvZmYKICAgIyBpcCBsaW5rIHNldCB2aWYwLjAgbXVsdGljYXN0IG9mZgog
ICAjIGlwIGxpbmsgc2V0IHZpZjAuMCBhZGRyIGZlOmZmOmZmOmZmOmZmOmZmCgogICAjIGlw
IGxpbmsgc2V0IHhlbmJyMCB1cAogICAjIGJyY3RsIGFkZGlmIHhlbmJyMCBib25kMAogICAj
IGlwIGxpbmsgc2V0IGJvbmQwIHVwCiAgICMgYnJjdGwgYWRkaWYgeGVuYnIwIHZpZjAuMAog
ICAjIGlwIGxpbmsgc2V0IHZpZjAuMCB1cAoKICAgIyBpcCBsaW5rIHNldCBldGgwIGFkZHIg
MDA6MTY6M2U6NzA6MDA6MDMKICAgIyBpcCBsaW5rIHNldCBldGgwIGFycCBvbgogICAjIGlm
dXAgZXRoMAogICAjIGlmY29uZmlnIGV0aDAgMTkyLjE2OC4wLjEKCg==
--------------030706080809070300090504--
