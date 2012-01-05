From: "Dave, Tushar N" <tushar.n.dave@intel.com>
Subject: RE: Detected Hardware Unit Hang on Intel Wired Ethernet
Date: Thu, 5 Jan 2012 23:54:32 +0000
Message-ID: <061C8A8601E8EE4CA8D8FD6990CEA89102D691@ORSMSX102.amr.corp.intel.com>
References: <CAHM4w1=i5dYy+ReqMO=m6W96CNaQ+O=jw+pKQok0nmjb5-fNAw@mail.gmail.com>
 <4F043190.70405@st.com> <20120104192234.GC18214@kroah.com>
 <4F05276F.6040708@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Pratyush Anand <pratyush.anand@gmail.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Shiraz HASHIM <shiraz.hashim@st.com>,
	Deepak SIKRI <deepak.sikri@st.com>,
	Bhavna YADAV <bhavna.yadav@st.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	Linux NICS <linuxnics@mailbox.intel.com>,
	"Dave, Tushar N" <tushar.n.dave@intel.com>
To: Pratyush Anand <pratyush.anand@st.com>, Greg KH <greg@kroah.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <4F05276F.6040708@st.com>
Content-Language: en-US
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Anand,

Sorry to hear that you have this issue with card. And yeah, thanks for doing the debugging and providing the bus trace. 
I think we should run the debug driver that prints the HW ring details when hang occurs. I can provide you a debug driver. You can then install debug driver and also let the bus tracer running. Once the issue occurs, provide me the full dmesg output (that has HW ring details) and bus trace. 

Tell me which card you have, 1gig or 10gig? Which driver are you running e1000e or igb or ixgbe?
Can you also provide ethtool -i ethx output.

Once I know which driver, I send you debug driver. 

Thanks.

-Tushar

-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On Behalf Of Pratyush Anand
Sent: Wednesday, January 04, 2012 8:31 PM
To: Greg KH
Cc: Pratyush Anand; e1000-devel@lists.sourceforge.net; netdev@vger.kernel.org; Shiraz HASHIM; Deepak SIKRI; Bhavna YADAV; linux-pci@vger.kernel.org; Linux NICS
Subject: Re: Detected Hardware Unit Hang on Intel Wired Ethernet

On 1/5/2012 12:52 AM, Greg KH wrote:
> On Wed, Jan 04, 2012 at 04:31:36PM +0530, Pratyush Anand wrote:
>> Adding PCI mailing list too, as problem is coming only when MSI is enabled.
>>
>> If I connect an PCIe analyzer, I see that at the time of issue
>> MRd(64) for 32 words has been issued with a wrong 64 bit address
>> from ethernet card to my RC.
>> In the normal course it always issues MRd(32) only.
>
> Bug in your pcie firmware controller?
>
> .
>

when you say "Bug in your pcie firmware controller?", is it RC's 
software or EP's software?

Here I am pasting a part of analyzer log converted into text.
Packet(177940), is an upstream request for MSI. Whenever any device 
writes at address 0x58A8F8, my PCIe RC considers it as MSI and generates 
an interrupt. So I receive MSI interrupt correctly in my software. Also 
MSI controller is correctly able to point me that the interrupt is from 
ethernet card.

Now in Packet(178010), ethernet controller sends another upstream 
request for MRd(64) of 32 dwords with Address(AFECEB87:A9D88B00).Since, 
this address does not exist in my RC's world so, an UR is returned and 
hence the problem occurs.

Now, question is, why ethernet card is generating inbound request with 
such a wrong address. I have taken log of all the tx_desc->buffer_addr 
programmed by software in function e1000_tx_queue. None of them is 64 
bit or any invalid address.

_______|_______________________________________________________________________
Packet(177916) Upstream 2.5(x1) TLP(1475) Mem MWr(32)(10:00000) Length(4)
_______| RequesterID(003:00:0) Tag(2) Address(0EB00200) 1st BE(1111)
_______| Last BE(1111) Data(4 dwords) LCRC(0x44E0407C)
_______| Time Stamp(0013 . 460 549 544 s)
_______|_______________________________________________________________________
Packet(177918) Downstream 2.5(x1) DLLP ACK AckNak_Seq_Num(1475)
_______| CRC 16(0x0EB7) Time Stamp(0013 . 460 551 144 s)
_______|_______________________________________________________________________
Packet(177940) Upstream 2.5(x1) TLP(1476) Mem MWr(32)(10:00000) Length(1)
_______| RequesterID(003:00:0) Tag(30) Address(0058A8F8) 1st BE(0011)
_______| Last BE(0000) Data(1 dword) LCRC(0xC21F32B6)
_______| Time Stamp(0013 . 460 588 544 s)
_______|_______________________________________________________________________
Packet(177942) Downstream 2.5(x1) DLLP ACK AckNak_Seq_Num(1476)
_______| CRC 16(0x69F5) Time Stamp(0013 . 460 590 088 s)
_______|_______________________________________________________________________
Packet(177946) Downstream 2.5(x1) TLP(309) Mem MRd(32)(00:00000) Length(1)
_______| RequesterID(002:00:0) Tag(19) Address(C01000C0) 1st BE(1111)
_______| Last BE(0000) LCRC(0x91BDA1F5) Time Stamp(0013 . 460 595 936 s)
_______|_______________________________________________________________________
Packet(177947) Upstream 2.5(x1) DLLP ACK AckNak_Seq_Num(309)
_______| CRC 16(0x25C6) Time Stamp(0013 . 460 596 368 s)
_______|_______________________________________________________________________
Packet(177950) Upstream 2.5(x1) TLP(1477) Cpl CplD(10:01010) Length(1)
_______| RequesterID(002:00:0) Tag(19) CompleterID(003:00:0) Status(SC) 
BCM(0)
_______| Byte Cnt(4) Lwr Addr(0x40) Data(1 dword) LCRC(0x8FE0D922)
_______| Time Stamp(0013 . 460 597 304 s)
_______|_______________________________________________________________________
Packet(177952) Downstream 2.5(x1) DLLP ACK AckNak_Seq_Num(1477)
_______| CRC 16(0xC8EE) Time Stamp(0013 . 460 598 840 s)
_______|_______________________________________________________________________
Packet(177999) Downstream 2.5(x1) TLP(310) Mem MWr(32)(10:00000) Length(1)
_______| RequesterID(002:00:0) Tag(0) Address(C0103818) 1st BE(1111)
_______| Last BE(0000) Data(1 dword) LCRC(0xA898D9A1)
_______| Time Stamp(0013 . 460 687 936 s)
_______|_______________________________________________________________________
Packet(178001) Upstream 2.5(x1) DLLP ACK AckNak_Seq_Num(310)
_______| CRC 16(0xC6EA) Time Stamp(0013 . 460 688 384 s)
_______|_______________________________________________________________________
Packet(178004) Upstream 2.5(x1) TLP(1478) Mem MRd(32)(00:00000) Length(4)
_______| RequesterID(003:00:0) Tag(4) Address(0EAFB990) 1st BE(1111)
_______| Last BE(1111) LCRC(0xB54722D2) Time Stamp(0013 . 460 689 312 s)
_______|_______________________________________________________________________
Packet(178006) Downstream 2.5(x1) TLP(311) Cpl CplD(10:01010) Length(4)
_______| RequesterID(003:00:0) Tag(4) CompleterID(002:00:0) Status(SC) 
BCM(0)
_______| Byte Cnt(16) Lwr Addr(0x10) Data(4 dwords) LCRC(0xFE303776)
_______| Time Stamp(0013 . 460 690 288 s)
_______|_______________________________________________________________________
Packet(178007) Upstream 2.5(x1) DLLP ACK AckNak_Seq_Num(311)
_______| CRC 16(0x67F1) Time Stamp(0013 . 460 690 776 s)
_______|_______________________________________________________________________
Packet(178008) Downstream 2.5(x1) DLLP ACK AckNak_Seq_Num(1478)
_______| CRC 16(0x2BC2) Time Stamp(0013 . 460 690 824 s)
_______|_______________________________________________________________________
Packet(178010) Upstream 2.5(x1) TLP(1479) Mem MRd(64)(01:00000) Length(32)
_______| RequesterID(003:00:0) Tag(11) Address(AFECEB87:A9D88B00) 1st 
BE(1100)
_______| Last BE(0011) LCRC(0x6BE341C9) Time Stamp(0013 . 460 691 680 s)
_______|_______________________________________________________________________
Packet(178011) Upstream 2.5(x1) TLP(1480) Mem MRd(64)(01:00000) Length(32)
_______| RequesterID(003:00:0) Tag(8) Address(AFECEB87:A9D88B7C) 1st 
BE(1100)
_______| Last BE(0011) LCRC(0xAA5647BD) Time Stamp(0013 . 460 691 808 s)
_______|_______________________________________________________________________
Packet(178012) Upstream 2.5(x1) TLP(1481) Mem MRd(64)(01:00000) Length(32)
_______| RequesterID(003:00:0) Tag(9) Address(AFECEB87:A9D88BF8) 1st 
BE(1100)
_______| Last BE(0011) LCRC(0xEEB1F63F) Time Stamp(0013 . 460 692 120 s)
_______|_______________________________________________________________________
Packet(178013) Upstream 2.5(x1) TLP(1482) Mem MRd(64)(01:00000) Length(32)
_______| RequesterID(003:00:0) Tag(10) Address(AFECEB87:A9D88C74) 1st 
BE(1100)
_______| Last BE(0011) LCRC(0xA508142C) Time Stamp(0013 . 460 692 248 s)
_______|_______________________________________________________________________
Packet(178014) Downstream 2.5(x1) TLP(312) Cpl Cpl(00:01010) Length(0)
_______| RequesterID(003:00:0) Tag(11) CompleterID(002:00:0) Status(UR)-BAD
_______| BCM(0) Byte Cnt(124) Lwr Addr(0x02) LCRC(0xCE5540D2)
_______| Time Stamp(0013 . 460 692 328 s)
_______|_______________________________________________________________________
Packet(178015) Downstream 2.5(x1) TLP(313) Cpl Cpl(00:01010) Length(0)
_______| RequesterID(003:00:0) Tag(8) CompleterID(002:00:0) Status(UR)-BAD
_______| BCM(0) Byte Cnt(124) Lwr Addr(0x7E) LCRC(0x9FE2487D)
_______| Time Stamp(0013 . 460 692 456 s)
_______|_______________________________________________________________________
Packet(178016) Upstream 2.5(x1) DLLP ACK AckNak_Seq_Num(312)
_______| CRC 16(0x086E) Time Stamp(0013 . 460 692 760 s)
_______|_______________________________________________________________________
Packet(178017) Downstream 2.5(x1) TLP(314) Cpl Cpl(00:01010) Length(0)
_______| RequesterID(003:00:0) Tag(9) CompleterID(002:00:0) Status(UR)-BAD
_______| BCM(0) Byte Cnt(124) Lwr Addr(0x7A) LCRC(0x097BF4DE)
_______| Time Stamp(0013 . 460 692 776 s)
_______|_______________________________________________________________________
Packet(178018) Upstream 2.5(x1) DLLP ACK AckNak_Seq_Num(313)
_______| CRC 16(0xA975) Time Stamp(0013 . 460 692 888 s)
_______|_______________________________________________________________________
Packet(178019) Downstream 2.5(x1) TLP(315) Cpl Cpl(00:01010) Length(0)
_______| RequesterID(003:00:0) Tag(10) CompleterID(002:00:0) Status(UR)-BAD
_______| BCM(0) Byte Cnt(124) Lwr Addr(0x76) LCRC(0x64BDF921)
_______| Time Stamp(0013 . 460 692 904 s)
_______|_______________________________________________________________________
Packet(178020) Upstream 2.5(x1) TLP(1483) Msg Msg(01:10000)
_______| Msg Routing(To RC) Length(0) RequesterID(003:00:0) Tag(31)
_______| Message Code(ERR_FATAL) LCRC(0xCDA53E96)
_______| Time Stamp(0013 . 460 693 184 s)
_______|_______________________________________________________________________
Packet(178021) Downstream 2.5(x1) DLLP ACK AckNak_Seq_Num(1482)
_______| CRC 16(0xA771) Time Stamp(0013 . 460 693 208 s)
_______|_______________________________________________________________________
Packet(178023) Upstream 2.5(x1) DLLP ACK AckNak_Seq_Num(314)
_______| CRC 16(0x4A59) Time Stamp(0013 . 460 693 280 s)
_______|_______________________________________________________________________
Packet(178024) Upstream 2.5(x1) TLP(1484) Msg Msg(01:10000)
_______| Msg Routing(To RC) Length(0) RequesterID(003:00:0) Tag(31)
_______| Message Code(ERR_FATAL) LCRC(0x86D9ACB6)
_______| Time Stamp(0013 . 460 693 312 s)
_______|_______________________________________________________________________
Packet(178025) Upstream 2.5(x1) DLLP ACK AckNak_Seq_Num(315)
_______| CRC 16(0xEB42) Time Stamp(0013 . 460 693 408 s)
_______|_______________________________________________________________________
Packet(178026) Upstream 2.5(x1) TLP(1485) Msg Msg(01:10000)
_______| Msg Routing(To RC) Length(0) RequesterID(003:00:0) Tag(31)
_______| Message Code(ERR_FATAL) LCRC(0xC5120A31)
_______| Time Stamp(0013 . 460 693 632 s)
_______|_______________________________________________________________________
Packet(178028) Upstream 2.5(x1) TLP(1486) Msg Msg(01:10000)
_______| Msg Routing(To RC) Length(0) RequesterID(003:00:0) Tag(31)
_______| Message Code(ERR_FATAL) LCRC(0x41499062)
_______| Time Stamp(0013 . 460 693 792 s)
_______|_______________________________________________________________________
Packet(178029) Downstream 2.5(x1) DLLP ACK AckNak_Seq_Num(1486)
_______| CRC 16(0x231F) Time Stamp(0013 . 460 694 704 s)
_______|_______________________________________________________________________

