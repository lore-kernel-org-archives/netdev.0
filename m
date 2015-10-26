From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC Patch 00/12] IXGBE: Add live migration support for SRIOV NIC
Date: Mon, 26 Oct 2015 08:03:23 -0700
Message-ID: <562E40BB.6040404@gmail.com>
References: <1445445464-5056-1-git-send-email-tianyu.lan@intel.com>
 <562A7E33.4080800@gmail.com> <562DBBC9.4000104@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Lan Tianyu <tianyu.lan@intel.com>, bhelgaas@google.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	eddie.dong@intel.com, nrupal.jani@intel.com,
	yang.z.zhang@intel.com, agraf@suse.de, kvm@vger.kernel.org,
	pbonzini@redhat.com, qemu-devel@nongnu.org,
	emil.s.tantilov@intel.com, intel-wired-lan@lists.osuosl.org,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	john.ronciak@intel.com, linux-kernel@vger.kernel.org,
	linux-pci@vger.kernel.org, matthew.vick@intel.com,
	mitch.a.williams@intel.com, netdev@vger.kernel.org,
	shannon.nelson@intel.com
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <562DBBC9.4000104@intel.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/25/2015 10:36 PM, Lan Tianyu wrote:
> On 2015=E5=B9=B410=E6=9C=8824=E6=97=A5 02:36, Alexander Duyck wrote:
>> I was thinking about it and I am pretty sure the dummy write approac=
h is
>> problematic at best.  Specifically the issue is that while you are
>> performing a dummy write you risk pulling in descriptors for data th=
at
>> hasn't been dummy written to yet.  So when you resume and restore yo=
ur
>> descriptors you will have once that may contain Rx descriptors
>> indicating they contain data when after the migration they don't.
> How about changing sequence? dummy writing Rx packet data fist and th=
en
> its desc. This can ensure that RX data is migrated before its desc an=
d
> prevent such case.

No.  I think you are missing the fact that there are 256 descriptors pe=
r=20
page.  As such if you dirty just 1 you will be pulling in 255 more, of=20
which you may or may not have pulled in the receive buffer for.

So for example if you have the descriptor ring size set to 256 then tha=
t=20
means you are going to get whatever the descriptor ring has since you=20
will be marking the entire ring dirty with every packet processed,=20
however you cannot guarantee that you are going to get all of the=20
receive buffers unless you go through and flush the entire ring prior t=
o=20
migrating.

This is why I have said you will need to do something to force the ring=
s=20
to be flushed such as initiating a PM suspend prior to migrating.  You=20
need to do something to stop the DMA and flush the remaining Rx buffers=
=20
if you want to have any hope of being able to migrate the Rx in a=20
consistent state.  Beyond that the only other thing you have to worry=20
about are the Rx buffers that have already been handed off to the=20
stack.  However those should be handled if you do a suspend and somehow=
=20
flag pages as dirty when they are unmapped from the DMA.

- Alex
