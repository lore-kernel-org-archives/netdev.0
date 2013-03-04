From: "Perla, Sathya" <Sathya.Perla@Emulex.Com>
Subject: RE: [PATCH 2/2] benet: Wait I/O while resuming device
Date: Mon, 4 Mar 2013 11:11:21 +0000
Message-ID: <67feeaf6-cd7c-4892-b76d-0344f9367ff4@CMEXHTCAS1.ad.emulex.com>
References: <1362383327-32362-1-git-send-email-shangw@linux.vnet.ibm.com>
 <1362383327-32362-2-git-send-email-shangw@linux.vnet.ibm.com>
 <1433171e-68da-4ebb-924f-e18b3f43858c@CMEXHTCAS2.ad.emulex.com>
 <20130304101841.GA20882@shangw.(null)>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Seetharaman, Subramanian" <subbu.seetharaman@emulex.com>,
	"Khaparde, Ajit" <Ajit.Khaparde@Emulex.Com>
To: Gavin Shan <shangw@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:29027 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756222Ab3CDLL1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Mar 2013 06:11:27 -0500
In-Reply-To: <20130304101841.GA20882@shangw.(null)>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Gavin Shan [mailto:shangw@linux.vnet.ibm.com]
> 
> On Mon, Mar 04, 2013 at 09:17:22AM +0000, Perla, Sathya wrote:
> >> -----Original Message-----
> >> From: Gavin Shan [mailto:shangw@linux.vnet.ibm.com]
> >>
> >> After resetting the adapter, the config space register (0x7c) might
> >> give fake information to indicate the f/w is ready. In turn, 0xFF's
> >> is always returned while accessing on I/O space registers. The patch
> >> adds more check to make sure the I/O space is ready for access before
> accessing that region.
> >>
> >...
> >>
> >> +int be_cmd_fw_wait_io(struct be_adapter *adapter) {
> >> +	void __iomem *db = adapter->db + MPU_MAILBOX_DB_OFFSET;
> >> +	int timeout = 0;
> >> +	u32 val;
> >> +
> >> +	if (lancer_chip(adapter))
> >> +		return 0;
> >> +
> >> +	do {
> >> +		val = ioread32(db);
> >> +		if (val != 0xffffffff)
> >> +			return 0;
> >Wouldn't reading 0xffffffff from a register cause a new EEH flow to be
> triggered?
> >
> 
> I don't think 0xffffffff here indicates a new EEH error and the adapter was
> recovering from EEH error, which already happened before.

> 
> Actually, I'm developing new feature to support EEH for PowerNV (PPC)
> platform. While the benet adapter detected EEH error and tried to resume, the
> I/O access always returned 0xffffffff even through I could get correct values
> from the config space. Since I don't have the specification, I would guess the
> config space becomes ready prior to I/O space after resetting the adapter and
> its firmware.

The root-cause here is that the config-space/0x7c register is incorrectly
reflecting the POST state to be FW_READY. This causes the driver to go ahead
and read I/O space "prematurely" causing a 0xffffffff read. 
The config-space/0x7c register reflects the correct
value a little later. This happens only for BE2/3 chips.

I propose to fix this by polling instead on CSR-BAR/0xac register for POST status
for BE2/3 chips.

thanks,
-Sathya
