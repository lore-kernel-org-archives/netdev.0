From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] irq: Add node_affinity CPU masks for smarter irqbalance
 hints
Date: Thu, 26 Nov 2009 12:43:51 +0100
Message-ID: <4B0E69F7.2020504@gmail.com>
References: <20091124.093956.247147202.davem@davemloft.net> <1259085412.2631.48.camel@ppwaskie-mobl2> <4B0C2547.8030408@gmail.com> <20091124.105442.06273019.davem@davemloft.net> <4B0C2CCA.6030006@gmail.com> <87iqczwtia.fsf@basil.nowhere.org> <4B0C4624.9080607@gmail.com> <4B0D0742.2050301@gmail.com> <20091125103713.GF29096@one.firstfloor.org> <4B0D1667.8050506@gmail.com> <20091125115019.GG29096@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	peter.p.waskiewicz.jr@intel.com, peterz@infradead.org,
	arjan@linux.intel.com, yong.zhang0@gmail.com,
	linux-kernel@vger.kernel.org, arjan@linux.jf.intel.com,
	netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:45352 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752078AbZKZLoQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2009 06:44:16 -0500
In-Reply-To: <20091125115019.GG29096@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen a =E9crit :

> That looks weird. It should have worked with CONFIG_NR_CPUS=3D=3D16 t=
oo,
> because you only have 16 CPUs and the NR_CPUS should affect APIC
> ranges etc.
>=20
> Something still fishy. I would properly report it.
>=20
> BTW kernel should give some error message in any case when
> there are not enough CPUs I guess.=20

Problem comes from acpi_numa_init(), calling

acpi_table_parse_srat(ACPI_SRAT_TYPE_CPU_AFFINITY, acpi_parse_processor=
_affinity, NR_CPUS);

But on this machine SRAT table contains 64 processor_affinity entries,
part of them enabled and other parts disabled

[8 ENABLED], [8 disabled], [8 ENABLED], [40 disabled]

So if NR_CPUS =3D 16, we 'see' only 8 enabled entries and 8 disabled en=
tries.

# acpidump  -t SRAT >SRAT.dump
# acpixtract -a SRAT.dump
# iasl -d SRAT.dat
# cat SRAT.dsl
/*
 * Intel ACPI Component Architecture
 * AML Disassembler version 20090521
 *
 * Disassembly of SRAT.dat, Thu Nov 26 12:29:34 2009
 *
 * ACPI Data Table [SRAT]
 *
 * Format: [HexOffset DecimalOffset ByteLength]  FieldName : FieldValue
 */

[000h 0000  4]                    Signature : "SRAT"    /* System Resou=
rce Affinity Table */
[004h 0004  4]                 Table Length : 00000570
[008h 0008  1]                     Revision : 01
[009h 0009  1]                     Checksum : D9
[00Ah 0010  6]                       Oem ID : "HP    "
[010h 0016  8]                 Oem Table ID : "Proliant"
[018h 0024  4]                 Oem Revision : 00000001
[01Ch 0028  4]              Asl Compiler ID : "    "
[020h 0032  4]        Asl Compiler Revision : 0000162E

[024h 0036  4]               Table Revision : 00000001
[028h 0040  8]                     Reserved : 0000000000000000

[030h 0048  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[031h 0049  1]                       Length : 10

[032h 0050  1]      Proximity Domain Low(8) : 00
[033h 0051  1]                      Apic ID : 00
[034h 0052  4]        Flags (decoded below) : 00000001
                                    Enabled : 1
[038h 0056  1]              Local Sapic EID : 00
[039h 0057  3]    Proximity Domain High(24) : 000000
[03Ch 0060  4]                     Reserved : 00000000

[040h 0064  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[041h 0065  1]                       Length : 10

[042h 0066  1]      Proximity Domain Low(8) : 00
[043h 0067  1]                      Apic ID : 01
[044h 0068  4]        Flags (decoded below) : 00000001
                                    Enabled : 1
[048h 0072  1]              Local Sapic EID : 00
[049h 0073  3]    Proximity Domain High(24) : 000000
[04Ch 0076  4]                     Reserved : 00000000

[050h 0080  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[051h 0081  1]                       Length : 10

[052h 0082  1]      Proximity Domain Low(8) : 00
[053h 0083  1]                      Apic ID : 02
[054h 0084  4]        Flags (decoded below) : 00000001
                                    Enabled : 1
[058h 0088  1]              Local Sapic EID : 00
[059h 0089  3]    Proximity Domain High(24) : 000000
[05Ch 0092  4]                     Reserved : 00000000

[060h 0096  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[061h 0097  1]                       Length : 10

[062h 0098  1]      Proximity Domain Low(8) : 00
[063h 0099  1]                      Apic ID : 03
[064h 0100  4]        Flags (decoded below) : 00000001
                                    Enabled : 1
[068h 0104  1]              Local Sapic EID : 00
[069h 0105  3]    Proximity Domain High(24) : 000000
[06Ch 0108  4]                     Reserved : 00000000

[070h 0112  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[071h 0113  1]                       Length : 10

[072h 0114  1]      Proximity Domain Low(8) : 00
[073h 0115  1]                      Apic ID : 04
[074h 0116  4]        Flags (decoded below) : 00000001
                                    Enabled : 1
[078h 0120  1]              Local Sapic EID : 00
[079h 0121  3]    Proximity Domain High(24) : 000000
[07Ch 0124  4]                     Reserved : 00000000

[080h 0128  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[081h 0129  1]                       Length : 10

[082h 0130  1]      Proximity Domain Low(8) : 00
[083h 0131  1]                      Apic ID : 05
[084h 0132  4]        Flags (decoded below) : 00000001
                                    Enabled : 1
[088h 0136  1]              Local Sapic EID : 00
[089h 0137  3]    Proximity Domain High(24) : 000000
[08Ch 0140  4]                     Reserved : 00000000

[090h 0144  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[091h 0145  1]                       Length : 10

[092h 0146  1]      Proximity Domain Low(8) : 00
[093h 0147  1]                      Apic ID : 06
[094h 0148  4]        Flags (decoded below) : 00000001
                                    Enabled : 1
[098h 0152  1]              Local Sapic EID : 00
[099h 0153  3]    Proximity Domain High(24) : 000000
[09Ch 0156  4]                     Reserved : 00000000

[0A0h 0160  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[0A1h 0161  1]                       Length : 10

[0A2h 0162  1]      Proximity Domain Low(8) : 00
[0A3h 0163  1]                      Apic ID : 07
[0A4h 0164  4]        Flags (decoded below) : 00000001
                                    Enabled : 1
[0A8h 0168  1]              Local Sapic EID : 00
[0A9h 0169  3]    Proximity Domain High(24) : 000000
[0ACh 0172  4]                     Reserved : 00000000

[0B0h 0176  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[0B1h 0177  1]                       Length : 10

[0B2h 0178  1]      Proximity Domain Low(8) : 00
[0B3h 0179  1]                      Apic ID : 08
[0B4h 0180  4]        Flags (decoded below) : 00000000
                                    Enabled : 0
[0B8h 0184  1]              Local Sapic EID : 00
[0B9h 0185  3]    Proximity Domain High(24) : 000000
[0BCh 0188  4]                     Reserved : 00000000

[0C0h 0192  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[0C1h 0193  1]                       Length : 10

[0C2h 0194  1]      Proximity Domain Low(8) : 00
[0C3h 0195  1]                      Apic ID : 09
[0C4h 0196  4]        Flags (decoded below) : 00000000
                                    Enabled : 0
[0C8h 0200  1]              Local Sapic EID : 00
[0C9h 0201  3]    Proximity Domain High(24) : 000000
[0CCh 0204  4]                     Reserved : 00000000

[0D0h 0208  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[0D1h 0209  1]                       Length : 10

[0D2h 0210  1]      Proximity Domain Low(8) : 00
[0D3h 0211  1]                      Apic ID : 0A
[0D4h 0212  4]        Flags (decoded below) : 00000000
                                    Enabled : 0
[0D8h 0216  1]              Local Sapic EID : 00
[0D9h 0217  3]    Proximity Domain High(24) : 000000
[0DCh 0220  4]                     Reserved : 00000000

[0E0h 0224  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[0E1h 0225  1]                       Length : 10

[0E2h 0226  1]      Proximity Domain Low(8) : 00
[0E3h 0227  1]                      Apic ID : 0B
[0E4h 0228  4]        Flags (decoded below) : 00000000
                                    Enabled : 0
[0E8h 0232  1]              Local Sapic EID : 00
[0E9h 0233  3]    Proximity Domain High(24) : 000000
[0ECh 0236  4]                     Reserved : 00000000

[0F0h 0240  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[0F1h 0241  1]                       Length : 10

[0F2h 0242  1]      Proximity Domain Low(8) : 00
[0F3h 0243  1]                      Apic ID : 0C
[0F4h 0244  4]        Flags (decoded below) : 00000000
                                    Enabled : 0
[0F8h 0248  1]              Local Sapic EID : 00
[0F9h 0249  3]    Proximity Domain High(24) : 000000
[0FCh 0252  4]                     Reserved : 00000000

[100h 0256  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[101h 0257  1]                       Length : 10

[102h 0258  1]      Proximity Domain Low(8) : 00
[103h 0259  1]                      Apic ID : 0D
[104h 0260  4]        Flags (decoded below) : 00000000
                                    Enabled : 0
[108h 0264  1]              Local Sapic EID : 00
[109h 0265  3]    Proximity Domain High(24) : 000000
[10Ch 0268  4]                     Reserved : 00000000

[110h 0272  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[111h 0273  1]                       Length : 10

[112h 0274  1]      Proximity Domain Low(8) : 00
[113h 0275  1]                      Apic ID : 0E
[114h 0276  4]        Flags (decoded below) : 00000000
                                    Enabled : 0
[118h 0280  1]              Local Sapic EID : 00
[119h 0281  3]    Proximity Domain High(24) : 000000
[11Ch 0284  4]                     Reserved : 00000000

[120h 0288  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[121h 0289  1]                       Length : 10

[122h 0290  1]      Proximity Domain Low(8) : 00
[123h 0291  1]                      Apic ID : 0F
[124h 0292  4]        Flags (decoded below) : 00000000
                                    Enabled : 0
[128h 0296  1]              Local Sapic EID : 00
[129h 0297  3]    Proximity Domain High(24) : 000000
[12Ch 0300  4]                     Reserved : 00000000

[130h 0304  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[131h 0305  1]                       Length : 10

[132h 0306  1]      Proximity Domain Low(8) : 01
[133h 0307  1]                      Apic ID : 10
[134h 0308  4]        Flags (decoded below) : 00000001
                                    Enabled : 1
[138h 0312  1]              Local Sapic EID : 00
[139h 0313  3]    Proximity Domain High(24) : 000000
[13Ch 0316  4]                     Reserved : 00000000

[140h 0320  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[141h 0321  1]                       Length : 10

[142h 0322  1]      Proximity Domain Low(8) : 01
[143h 0323  1]                      Apic ID : 11
[144h 0324  4]        Flags (decoded below) : 00000001
                                    Enabled : 1
[148h 0328  1]              Local Sapic EID : 00
[149h 0329  3]    Proximity Domain High(24) : 000000
[14Ch 0332  4]                     Reserved : 00000000

[150h 0336  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[151h 0337  1]                       Length : 10

[152h 0338  1]      Proximity Domain Low(8) : 01
[153h 0339  1]                      Apic ID : 12
[154h 0340  4]        Flags (decoded below) : 00000001
                                    Enabled : 1
[158h 0344  1]              Local Sapic EID : 00
[159h 0345  3]    Proximity Domain High(24) : 000000
[15Ch 0348  4]                     Reserved : 00000000

[160h 0352  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[161h 0353  1]                       Length : 10

[162h 0354  1]      Proximity Domain Low(8) : 01
[163h 0355  1]                      Apic ID : 13
[164h 0356  4]        Flags (decoded below) : 00000001
                                    Enabled : 1
[168h 0360  1]              Local Sapic EID : 00
[169h 0361  3]    Proximity Domain High(24) : 000000
[16Ch 0364  4]                     Reserved : 00000000

[170h 0368  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[171h 0369  1]                       Length : 10

[172h 0370  1]      Proximity Domain Low(8) : 01
[173h 0371  1]                      Apic ID : 14
[174h 0372  4]        Flags (decoded below) : 00000001
                                    Enabled : 1
[178h 0376  1]              Local Sapic EID : 00
[179h 0377  3]    Proximity Domain High(24) : 000000
[17Ch 0380  4]                     Reserved : 00000000

[180h 0384  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[181h 0385  1]                       Length : 10

[182h 0386  1]      Proximity Domain Low(8) : 01
[183h 0387  1]                      Apic ID : 15
[184h 0388  4]        Flags (decoded below) : 00000001
                                    Enabled : 1
[188h 0392  1]              Local Sapic EID : 00
[189h 0393  3]    Proximity Domain High(24) : 000000
[18Ch 0396  4]                     Reserved : 00000000

[190h 0400  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[191h 0401  1]                       Length : 10

[192h 0402  1]      Proximity Domain Low(8) : 01
[193h 0403  1]                      Apic ID : 16
[194h 0404  4]        Flags (decoded below) : 00000001
                                    Enabled : 1
[198h 0408  1]              Local Sapic EID : 00
[199h 0409  3]    Proximity Domain High(24) : 000000
[19Ch 0412  4]                     Reserved : 00000000

[1A0h 0416  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[1A1h 0417  1]                       Length : 10

[1A2h 0418  1]      Proximity Domain Low(8) : 01
[1A3h 0419  1]                      Apic ID : 17
[1A4h 0420  4]        Flags (decoded below) : 00000001
                                    Enabled : 1
[1A8h 0424  1]              Local Sapic EID : 00
[1A9h 0425  3]    Proximity Domain High(24) : 000000
[1ACh 0428  4]                     Reserved : 00000000

[1B0h 0432  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[1B1h 0433  1]                       Length : 10

[1B2h 0434  1]      Proximity Domain Low(8) : 00
[1B3h 0435  1]                      Apic ID : 18
[1B4h 0436  4]        Flags (decoded below) : 00000000
                                    Enabled : 0
[1B8h 0440  1]              Local Sapic EID : 00
[1B9h 0441  3]    Proximity Domain High(24) : 000000
[1BCh 0444  4]                     Reserved : 00000000

[1C0h 0448  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[1C1h 0449  1]                       Length : 10

[1C2h 0450  1]      Proximity Domain Low(8) : 00
[1C3h 0451  1]                      Apic ID : 19
[1C4h 0452  4]        Flags (decoded below) : 00000000
                                    Enabled : 0
[1C8h 0456  1]              Local Sapic EID : 00
[1C9h 0457  3]    Proximity Domain High(24) : 000000
[1CCh 0460  4]                     Reserved : 00000000

[1D0h 0464  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[1D1h 0465  1]                       Length : 10

[1D2h 0466  1]      Proximity Domain Low(8) : 00
[1D3h 0467  1]                      Apic ID : 1A
[1D4h 0468  4]        Flags (decoded below) : 00000000
                                    Enabled : 0
[1D8h 0472  1]              Local Sapic EID : 00
[1D9h 0473  3]    Proximity Domain High(24) : 000000
[1DCh 0476  4]                     Reserved : 00000000

[1E0h 0480  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[1E1h 0481  1]                       Length : 10

[1E2h 0482  1]      Proximity Domain Low(8) : 00
[1E3h 0483  1]                      Apic ID : 1B
[1E4h 0484  4]        Flags (decoded below) : 00000000
                                    Enabled : 0
[1E8h 0488  1]              Local Sapic EID : 00
[1E9h 0489  3]    Proximity Domain High(24) : 000000
[1ECh 0492  4]                     Reserved : 00000000

[1F0h 0496  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[1F1h 0497  1]                       Length : 10

[1F2h 0498  1]      Proximity Domain Low(8) : 00
[1F3h 0499  1]                      Apic ID : 1C
[1F4h 0500  4]        Flags (decoded below) : 00000000
                                    Enabled : 0
[1F8h 0504  1]              Local Sapic EID : 00
[1F9h 0505  3]    Proximity Domain High(24) : 000000
[1FCh 0508  4]                     Reserved : 00000000

[200h 0512  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[201h 0513  1]                       Length : 10

[202h 0514  1]      Proximity Domain Low(8) : 00
[203h 0515  1]                      Apic ID : 1D
[204h 0516  4]        Flags (decoded below) : 00000000
                                    Enabled : 0
[208h 0520  1]              Local Sapic EID : 00
[209h 0521  3]    Proximity Domain High(24) : 000000
[20Ch 0524  4]                     Reserved : 00000000

[210h 0528  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[211h 0529  1]                       Length : 10

[212h 0530  1]      Proximity Domain Low(8) : 00
[213h 0531  1]                      Apic ID : 1E
[214h 0532  4]        Flags (decoded below) : 00000000
                                    Enabled : 0
[218h 0536  1]              Local Sapic EID : 00
[219h 0537  3]    Proximity Domain High(24) : 000000
[21Ch 0540  4]                     Reserved : 00000000

[220h 0544  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[221h 0545  1]                       Length : 10

[222h 0546  1]      Proximity Domain Low(8) : 00
[223h 0547  1]                      Apic ID : 1F
[224h 0548  4]        Flags (decoded below) : 00000000
                                    Enabled : 0
[228h 0552  1]              Local Sapic EID : 00
[229h 0553  3]    Proximity Domain High(24) : 000000
[22Ch 0556  4]                     Reserved : 00000000

[230h 0560  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[231h 0561  1]                       Length : 10

[232h 0562  1]      Proximity Domain Low(8) : 00
[233h 0563  1]                      Apic ID : 20
[234h 0564  4]        Flags (decoded below) : 00000000
                                    Enabled : 0
[238h 0568  1]              Local Sapic EID : 00
[239h 0569  3]    Proximity Domain High(24) : 000000
[23Ch 0572  4]                     Reserved : 00000000

[240h 0576  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[241h 0577  1]                       Length : 10

[242h 0578  1]      Proximity Domain Low(8) : 00
[243h 0579  1]                      Apic ID : 21
[244h 0580  4]        Flags (decoded below) : 00000000
                                    Enabled : 0
[248h 0584  1]              Local Sapic EID : 00
[249h 0585  3]    Proximity Domain High(24) : 000000
[24Ch 0588  4]                     Reserved : 00000000

[250h 0592  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[251h 0593  1]                       Length : 10

[252h 0594  1]      Proximity Domain Low(8) : 00
[253h 0595  1]                      Apic ID : 22
[254h 0596  4]        Flags (decoded below) : 00000000
                                    Enabled : 0
[258h 0600  1]              Local Sapic EID : 00
[259h 0601  3]    Proximity Domain High(24) : 000000
[25Ch 0604  4]                     Reserved : 00000000

[260h 0608  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[261h 0609  1]                       Length : 10

[262h 0610  1]      Proximity Domain Low(8) : 00
[263h 0611  1]                      Apic ID : 23
[264h 0612  4]        Flags (decoded below) : 00000000
                                    Enabled : 0
[268h 0616  1]              Local Sapic EID : 00
[269h 0617  3]    Proximity Domain High(24) : 000000
[26Ch 0620  4]                     Reserved : 00000000

[270h 0624  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[271h 0625  1]                       Length : 10

[272h 0626  1]      Proximity Domain Low(8) : 00
[273h 0627  1]                      Apic ID : 24
[274h 0628  4]        Flags (decoded below) : 00000000
                                    Enabled : 0
[278h 0632  1]              Local Sapic EID : 00
[279h 0633  3]    Proximity Domain High(24) : 000000
[27Ch 0636  4]                     Reserved : 00000000

[280h 0640  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[281h 0641  1]                       Length : 10

[282h 0642  1]      Proximity Domain Low(8) : 00
[283h 0643  1]                      Apic ID : 25
[284h 0644  4]        Flags (decoded below) : 00000000
                                    Enabled : 0
[288h 0648  1]              Local Sapic EID : 00
[289h 0649  3]    Proximity Domain High(24) : 000000
[28Ch 0652  4]                     Reserved : 00000000

[290h 0656  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[291h 0657  1]                       Length : 10

[292h 0658  1]      Proximity Domain Low(8) : 00
[293h 0659  1]                      Apic ID : 26
[294h 0660  4]        Flags (decoded below) : 00000000
                                    Enabled : 0
[298h 0664  1]              Local Sapic EID : 00
[299h 0665  3]    Proximity Domain High(24) : 000000
[29Ch 0668  4]                     Reserved : 00000000

[2A0h 0672  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[2A1h 0673  1]                       Length : 10

[2A2h 0674  1]      Proximity Domain Low(8) : 00
[2A3h 0675  1]                      Apic ID : 27
[2A4h 0676  4]        Flags (decoded below) : 00000000
                                    Enabled : 0
[2A8h 0680  1]              Local Sapic EID : 00
[2A9h 0681  3]    Proximity Domain High(24) : 000000
[2ACh 0684  4]                     Reserved : 00000000

[2B0h 0688  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[2B1h 0689  1]                       Length : 10

[2B2h 0690  1]      Proximity Domain Low(8) : 00
[2B3h 0691  1]                      Apic ID : 28
[2B4h 0692  4]        Flags (decoded below) : 00000000
                                    Enabled : 0
[2B8h 0696  1]              Local Sapic EID : 00
[2B9h 0697  3]    Proximity Domain High(24) : 000000
[2BCh 0700  4]                     Reserved : 00000000

[2C0h 0704  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[2C1h 0705  1]                       Length : 10

[2C2h 0706  1]      Proximity Domain Low(8) : 00
[2C3h 0707  1]                      Apic ID : 29
[2C4h 0708  4]        Flags (decoded below) : 00000000
                                    Enabled : 0
[2C8h 0712  1]              Local Sapic EID : 00
[2C9h 0713  3]    Proximity Domain High(24) : 000000
[2CCh 0716  4]                     Reserved : 00000000

[2D0h 0720  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[2D1h 0721  1]                       Length : 10

[2D2h 0722  1]      Proximity Domain Low(8) : 00
[2D3h 0723  1]                      Apic ID : 2A
[2D4h 0724  4]        Flags (decoded below) : 00000000
                                    Enabled : 0
[2D8h 0728  1]              Local Sapic EID : 00
[2D9h 0729  3]    Proximity Domain High(24) : 000000
[2DCh 0732  4]                     Reserved : 00000000

[2E0h 0736  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[2E1h 0737  1]                       Length : 10

[2E2h 0738  1]      Proximity Domain Low(8) : 00
[2E3h 0739  1]                      Apic ID : 2B
[2E4h 0740  4]        Flags (decoded below) : 00000000
                                    Enabled : 0
[2E8h 0744  1]              Local Sapic EID : 00
[2E9h 0745  3]    Proximity Domain High(24) : 000000
[2ECh 0748  4]                     Reserved : 00000000

[2F0h 0752  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[2F1h 0753  1]                       Length : 10

[2F2h 0754  1]      Proximity Domain Low(8) : 00
[2F3h 0755  1]                      Apic ID : 2C
[2F4h 0756  4]        Flags (decoded below) : 00000000
                                    Enabled : 0
[2F8h 0760  1]              Local Sapic EID : 00
[2F9h 0761  3]    Proximity Domain High(24) : 000000
[2FCh 0764  4]                     Reserved : 00000000

[300h 0768  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[301h 0769  1]                       Length : 10

[302h 0770  1]      Proximity Domain Low(8) : 00
[303h 0771  1]                      Apic ID : 2D
[304h 0772  4]        Flags (decoded below) : 00000000
                                    Enabled : 0
[308h 0776  1]              Local Sapic EID : 00
[309h 0777  3]    Proximity Domain High(24) : 000000
[30Ch 0780  4]                     Reserved : 00000000

[310h 0784  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[311h 0785  1]                       Length : 10

[312h 0786  1]      Proximity Domain Low(8) : 00
[313h 0787  1]                      Apic ID : 2E
[314h 0788  4]        Flags (decoded below) : 00000000
                                    Enabled : 0
[318h 0792  1]              Local Sapic EID : 00
[319h 0793  3]    Proximity Domain High(24) : 000000
[31Ch 0796  4]                     Reserved : 00000000

[320h 0800  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[321h 0801  1]                       Length : 10

[322h 0802  1]      Proximity Domain Low(8) : 00
[323h 0803  1]                      Apic ID : 2F
[324h 0804  4]        Flags (decoded below) : 00000000
                                    Enabled : 0
[328h 0808  1]              Local Sapic EID : 00
[329h 0809  3]    Proximity Domain High(24) : 000000
[32Ch 0812  4]                     Reserved : 00000000

[330h 0816  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[331h 0817  1]                       Length : 10

[332h 0818  1]      Proximity Domain Low(8) : 00
[333h 0819  1]                      Apic ID : 30
[334h 0820  4]        Flags (decoded below) : 00000000
                                    Enabled : 0
[338h 0824  1]              Local Sapic EID : 00
[339h 0825  3]    Proximity Domain High(24) : 000000
[33Ch 0828  4]                     Reserved : 00000000

[340h 0832  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[341h 0833  1]                       Length : 10

[342h 0834  1]      Proximity Domain Low(8) : 00
[343h 0835  1]                      Apic ID : 31
[344h 0836  4]        Flags (decoded below) : 00000000
                                    Enabled : 0
[348h 0840  1]              Local Sapic EID : 00
[349h 0841  3]    Proximity Domain High(24) : 000000
[34Ch 0844  4]                     Reserved : 00000000

[350h 0848  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[351h 0849  1]                       Length : 10

[352h 0850  1]      Proximity Domain Low(8) : 00
[353h 0851  1]                      Apic ID : 32
[354h 0852  4]        Flags (decoded below) : 00000000
                                    Enabled : 0
[358h 0856  1]              Local Sapic EID : 00
[359h 0857  3]    Proximity Domain High(24) : 000000
[35Ch 0860  4]                     Reserved : 00000000

[360h 0864  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[361h 0865  1]                       Length : 10

[362h 0866  1]      Proximity Domain Low(8) : 00
[363h 0867  1]                      Apic ID : 33
[364h 0868  4]        Flags (decoded below) : 00000000
                                    Enabled : 0
[368h 0872  1]              Local Sapic EID : 00
[369h 0873  3]    Proximity Domain High(24) : 000000
[36Ch 0876  4]                     Reserved : 00000000

[370h 0880  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[371h 0881  1]                       Length : 10

[372h 0882  1]      Proximity Domain Low(8) : 00
[373h 0883  1]                      Apic ID : 34
[374h 0884  4]        Flags (decoded below) : 00000000
                                    Enabled : 0
[378h 0888  1]              Local Sapic EID : 00
[379h 0889  3]    Proximity Domain High(24) : 000000
[37Ch 0892  4]                     Reserved : 00000000

[380h 0896  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[381h 0897  1]                       Length : 10

[382h 0898  1]      Proximity Domain Low(8) : 00
[383h 0899  1]                      Apic ID : 35
[384h 0900  4]        Flags (decoded below) : 00000000
                                    Enabled : 0
[388h 0904  1]              Local Sapic EID : 00
[389h 0905  3]    Proximity Domain High(24) : 000000
[38Ch 0908  4]                     Reserved : 00000000

[390h 0912  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[391h 0913  1]                       Length : 10

[392h 0914  1]      Proximity Domain Low(8) : 00
[393h 0915  1]                      Apic ID : 36
[394h 0916  4]        Flags (decoded below) : 00000000
                                    Enabled : 0
[398h 0920  1]              Local Sapic EID : 00
[399h 0921  3]    Proximity Domain High(24) : 000000
[39Ch 0924  4]                     Reserved : 00000000

[3A0h 0928  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[3A1h 0929  1]                       Length : 10

[3A2h 0930  1]      Proximity Domain Low(8) : 00
[3A3h 0931  1]                      Apic ID : 37
[3A4h 0932  4]        Flags (decoded below) : 00000000
                                    Enabled : 0
[3A8h 0936  1]              Local Sapic EID : 00
[3A9h 0937  3]    Proximity Domain High(24) : 000000
[3ACh 0940  4]                     Reserved : 00000000

[3B0h 0944  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[3B1h 0945  1]                       Length : 10

[3B2h 0946  1]      Proximity Domain Low(8) : 00
[3B3h 0947  1]                      Apic ID : 38
[3B4h 0948  4]        Flags (decoded below) : 00000000
                                    Enabled : 0
[3B8h 0952  1]              Local Sapic EID : 00
[3B9h 0953  3]    Proximity Domain High(24) : 000000
[3BCh 0956  4]                     Reserved : 00000000

[3C0h 0960  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[3C1h 0961  1]                       Length : 10

[3C2h 0962  1]      Proximity Domain Low(8) : 00
[3C3h 0963  1]                      Apic ID : 39
[3C4h 0964  4]        Flags (decoded below) : 00000000
                                    Enabled : 0
[3C8h 0968  1]              Local Sapic EID : 00
[3C9h 0969  3]    Proximity Domain High(24) : 000000
[3CCh 0972  4]                     Reserved : 00000000

[3D0h 0976  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[3D1h 0977  1]                       Length : 10

[3D2h 0978  1]      Proximity Domain Low(8) : 00
[3D3h 0979  1]                      Apic ID : 3A
[3D4h 0980  4]        Flags (decoded below) : 00000000
                                    Enabled : 0
[3D8h 0984  1]              Local Sapic EID : 00
[3D9h 0985  3]    Proximity Domain High(24) : 000000
[3DCh 0988  4]                     Reserved : 00000000

[3E0h 0992  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[3E1h 0993  1]                       Length : 10

[3E2h 0994  1]      Proximity Domain Low(8) : 00
[3E3h 0995  1]                      Apic ID : 3B
[3E4h 0996  4]        Flags (decoded below) : 00000000
                                    Enabled : 0
[3E8h 1000  1]              Local Sapic EID : 00
[3E9h 1001  3]    Proximity Domain High(24) : 000000
[3ECh 1004  4]                     Reserved : 00000000

[3F0h 1008  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[3F1h 1009  1]                       Length : 10

[3F2h 1010  1]      Proximity Domain Low(8) : 00
[3F3h 1011  1]                      Apic ID : 3C
[3F4h 1012  4]        Flags (decoded below) : 00000000
                                    Enabled : 0
[3F8h 1016  1]              Local Sapic EID : 00
[3F9h 1017  3]    Proximity Domain High(24) : 000000
[3FCh 1020  4]                     Reserved : 00000000

[400h 1024  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[401h 1025  1]                       Length : 10

[402h 1026  1]      Proximity Domain Low(8) : 00
[403h 1027  1]                      Apic ID : 3D
[404h 1028  4]        Flags (decoded below) : 00000000
                                    Enabled : 0
[408h 1032  1]              Local Sapic EID : 00
[409h 1033  3]    Proximity Domain High(24) : 000000
[40Ch 1036  4]                     Reserved : 00000000

[410h 1040  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[411h 1041  1]                       Length : 10

[412h 1042  1]      Proximity Domain Low(8) : 00
[413h 1043  1]                      Apic ID : 3E
[414h 1044  4]        Flags (decoded below) : 00000000
                                    Enabled : 0
[418h 1048  1]              Local Sapic EID : 00
[419h 1049  3]    Proximity Domain High(24) : 000000
[41Ch 1052  4]                     Reserved : 00000000

[420h 1056  1]                Subtable Type : 00 <Processor Local APIC/=
SAPIC Affinity>
[421h 1057  1]                       Length : 10

[422h 1058  1]      Proximity Domain Low(8) : 00
[423h 1059  1]                      Apic ID : 3F
[424h 1060  4]        Flags (decoded below) : 00000000
                                    Enabled : 0
[428h 1064  1]              Local Sapic EID : 00
[429h 1065  3]    Proximity Domain High(24) : 000000
[42Ch 1068  4]                     Reserved : 00000000

[430h 1072  1]                Subtable Type : 01 <Memory Affinity>
[431h 1073  1]                       Length : 28

[432h 1074  4]             Proximity Domain : 00000000
[436h 1078  2]                     Reserved : 0000
[438h 1080  8]                 Base Address : 0000000000000000
[440h 1088  8]               Address Length : 00000000E0000000
[448h 1096  4]                     Reserved : 00000000
[44Ch 1100  4]        Flags (decoded below) : 00000001
                                    Enabled : 1
                              Hot Pluggable : 0
                               Non-Volatile : 0
[450h 1104  8]                     Reserved : 0000000000000000

[458h 1112  1]                Subtable Type : 01 <Memory Affinity>
[459h 1113  1]                       Length : 28

[45Ah 1114  4]             Proximity Domain : 00000000
[45Eh 1118  2]                     Reserved : 0000
[460h 1120  8]                 Base Address : 00000000E0000000
[468h 1128  8]               Address Length : 0000000020000000
[470h 1136  4]                     Reserved : 00000000
[474h 1140  4]        Flags (decoded below) : 00000000
                                    Enabled : 0
                              Hot Pluggable : 0
                               Non-Volatile : 0
[478h 1144  8]                     Reserved : 0000000000000000

[480h 1152  1]                Subtable Type : 01 <Memory Affinity>
[481h 1153  1]                       Length : 28

[482h 1154  4]             Proximity Domain : 00000000
[486h 1158  2]                     Reserved : 0000
[488h 1160  8]                 Base Address : 0000000100000000
[490h 1168  8]               Address Length : 0000000120000000
[498h 1176  4]                     Reserved : 00000000
[49Ch 1180  4]        Flags (decoded below) : 00000001
                                    Enabled : 1
                              Hot Pluggable : 0
                               Non-Volatile : 0
[4A0h 1184  8]                     Reserved : 0000000000000000

[4A8h 1192  1]                Subtable Type : 01 <Memory Affinity>
[4A9h 1193  1]                       Length : 28

[4AAh 1194  4]             Proximity Domain : 00000001
[4AEh 1198  2]                     Reserved : 0000
[4B0h 1200  8]                 Base Address : 0000000220000000
[4B8h 1208  8]               Address Length : 0000000200000000
[4C0h 1216  4]                     Reserved : 00000000
[4C4h 1220  4]        Flags (decoded below) : 00000001
                                    Enabled : 1
                              Hot Pluggable : 0
                               Non-Volatile : 0
[4C8h 1224  8]                     Reserved : 0000000000000000

[4D0h 1232  1]                Subtable Type : 01 <Memory Affinity>
[4D1h 1233  1]                       Length : 28

[4D2h 1234  4]             Proximity Domain : 00000000
[4D6h 1238  2]                     Reserved : 0000
[4D8h 1240  8]                 Base Address : 0000000420000000
[4E0h 1248  8]               Address Length : 0000000000000000
[4E8h 1256  4]                     Reserved : 00000000
[4ECh 1260  4]        Flags (decoded below) : 00000000
                                    Enabled : 0
                              Hot Pluggable : 0
                               Non-Volatile : 0
[4F0h 1264  8]                     Reserved : 0000000000000000

[4F8h 1272  1]                Subtable Type : 01 <Memory Affinity>
[4F9h 1273  1]                       Length : 28

[4FAh 1274  4]             Proximity Domain : 00000000
[4FEh 1278  2]                     Reserved : 0000
[500h 1280  8]                 Base Address : 0000000420000000
[508h 1288  8]               Address Length : 0000000000000000
[510h 1296  4]                     Reserved : 00000000
[514h 1300  4]        Flags (decoded below) : 00000000
                                    Enabled : 0
                              Hot Pluggable : 0
                               Non-Volatile : 0
[518h 1304  8]                     Reserved : 0000000000000000

[520h 1312  1]                Subtable Type : 01 <Memory Affinity>
[521h 1313  1]                       Length : 28

[522h 1314  4]             Proximity Domain : 00000000
[526h 1318  2]                     Reserved : 0000
[528h 1320  8]                 Base Address : 0000000420000000
[530h 1328  8]               Address Length : 0000000000000000
[538h 1336  4]                     Reserved : 00000000
[53Ch 1340  4]        Flags (decoded below) : 00000000
                                    Enabled : 0
                              Hot Pluggable : 0
                               Non-Volatile : 0
[540h 1344  8]                     Reserved : 0000000000000000

[548h 1352  1]                Subtable Type : 01 <Memory Affinity>
[549h 1353  1]                       Length : 28

[54Ah 1354  4]             Proximity Domain : 00000000
[54Eh 1358  2]                     Reserved : 0000
[550h 1360  8]                 Base Address : 0000000420000000
[558h 1368  8]               Address Length : 0000000000000000
[560h 1376  4]                     Reserved : 00000000
[564h 1380  4]        Flags (decoded below) : 00000000
                                    Enabled : 0
                              Hot Pluggable : 0
                               Non-Volatile : 0
[568h 1384  8]                     Reserved : 0000000000000000

Raw Table Data

  0000: 53 52 41 54 70 05 00 00 01 D9 48 50 20 20 20 20  SRATp.....HP  =
 =20
  0010: 50 72 6F 6C 69 61 6E 74 01 00 00 00 20 20 20 20  Proliant....  =
 =20
  0020: 2E 16 00 00 01 00 00 00 00 00 00 00 00 00 00 00  ..............=
=2E.
  0030: 00 10 00 00 01 00 00 00 00 00 00 00 00 00 00 00  ..............=
=2E.
  0040: 00 10 00 01 01 00 00 00 00 00 00 00 00 00 00 00  ..............=
=2E.
  0050: 00 10 00 02 01 00 00 00 00 00 00 00 00 00 00 00  ..............=
=2E.
  0060: 00 10 00 03 01 00 00 00 00 00 00 00 00 00 00 00  ..............=
=2E.
  0070: 00 10 00 04 01 00 00 00 00 00 00 00 00 00 00 00  ..............=
=2E.
  0080: 00 10 00 05 01 00 00 00 00 00 00 00 00 00 00 00  ..............=
=2E.
  0090: 00 10 00 06 01 00 00 00 00 00 00 00 00 00 00 00  ..............=
=2E.
  00A0: 00 10 00 07 01 00 00 00 00 00 00 00 00 00 00 00  ..............=
=2E.
  00B0: 00 10 00 08 00 00 00 00 00 00 00 00 00 00 00 00  ..............=
=2E.
  00C0: 00 10 00 09 00 00 00 00 00 00 00 00 00 00 00 00  ..............=
=2E.
  00D0: 00 10 00 0A 00 00 00 00 00 00 00 00 00 00 00 00  ..............=
=2E.
  00E0: 00 10 00 0B 00 00 00 00 00 00 00 00 00 00 00 00  ..............=
=2E.
  00F0: 00 10 00 0C 00 00 00 00 00 00 00 00 00 00 00 00  ..............=
=2E.
  0100: 00 10 00 0D 00 00 00 00 00 00 00 00 00 00 00 00  ..............=
=2E.
  0110: 00 10 00 0E 00 00 00 00 00 00 00 00 00 00 00 00  ..............=
=2E.
  0120: 00 10 00 0F 00 00 00 00 00 00 00 00 00 00 00 00  ..............=
=2E.
  0130: 00 10 01 10 01 00 00 00 00 00 00 00 00 00 00 00  ..............=
=2E.
  0140: 00 10 01 11 01 00 00 00 00 00 00 00 00 00 00 00  ..............=
=2E.
  0150: 00 10 01 12 01 00 00 00 00 00 00 00 00 00 00 00  ..............=
=2E.
  0160: 00 10 01 13 01 00 00 00 00 00 00 00 00 00 00 00  ..............=
=2E.
  0170: 00 10 01 14 01 00 00 00 00 00 00 00 00 00 00 00  ..............=
=2E.
  0180: 00 10 01 15 01 00 00 00 00 00 00 00 00 00 00 00  ..............=
=2E.
  0190: 00 10 01 16 01 00 00 00 00 00 00 00 00 00 00 00  ..............=
=2E.
  01A0: 00 10 01 17 01 00 00 00 00 00 00 00 00 00 00 00  ..............=
=2E.
  01B0: 00 10 00 18 00 00 00 00 00 00 00 00 00 00 00 00  ..............=
=2E.
  01C0: 00 10 00 19 00 00 00 00 00 00 00 00 00 00 00 00  ..............=
=2E.
  01D0: 00 10 00 1A 00 00 00 00 00 00 00 00 00 00 00 00  ..............=
=2E.
  01E0: 00 10 00 1B 00 00 00 00 00 00 00 00 00 00 00 00  ..............=
=2E.
  01F0: 00 10 00 1C 00 00 00 00 00 00 00 00 00 00 00 00  ..............=
=2E.
  0200: 00 10 00 1D 00 00 00 00 00 00 00 00 00 00 00 00  ..............=
=2E.
  0210: 00 10 00 1E 00 00 00 00 00 00 00 00 00 00 00 00  ..............=
=2E.
  0220: 00 10 00 1F 00 00 00 00 00 00 00 00 00 00 00 00  ..............=
=2E.
  0230: 00 10 00 20 00 00 00 00 00 00 00 00 00 00 00 00  ... ..........=
=2E.
  0240: 00 10 00 21 00 00 00 00 00 00 00 00 00 00 00 00  ...!..........=
=2E.
  0250: 00 10 00 22 00 00 00 00 00 00 00 00 00 00 00 00  ..."..........=
=2E.
  0260: 00 10 00 23 00 00 00 00 00 00 00 00 00 00 00 00  ...#..........=
=2E.
  0270: 00 10 00 24 00 00 00 00 00 00 00 00 00 00 00 00  ...$..........=
=2E.
  0280: 00 10 00 25 00 00 00 00 00 00 00 00 00 00 00 00  ...%..........=
=2E.
  0290: 00 10 00 26 00 00 00 00 00 00 00 00 00 00 00 00  ...&..........=
=2E.
  02A0: 00 10 00 27 00 00 00 00 00 00 00 00 00 00 00 00  ...'..........=
=2E.
  02B0: 00 10 00 28 00 00 00 00 00 00 00 00 00 00 00 00  ...(..........=
=2E.
  02C0: 00 10 00 29 00 00 00 00 00 00 00 00 00 00 00 00  ...)..........=
=2E.
  02D0: 00 10 00 2A 00 00 00 00 00 00 00 00 00 00 00 00  ...*..........=
=2E.
  02E0: 00 10 00 2B 00 00 00 00 00 00 00 00 00 00 00 00  ...+..........=
=2E.
  02F0: 00 10 00 2C 00 00 00 00 00 00 00 00 00 00 00 00  ...,..........=
=2E.
  0300: 00 10 00 2D 00 00 00 00 00 00 00 00 00 00 00 00  ...-..........=
=2E.
  0310: 00 10 00 2E 00 00 00 00 00 00 00 00 00 00 00 00  ..............=
=2E.
  0320: 00 10 00 2F 00 00 00 00 00 00 00 00 00 00 00 00  .../..........=
=2E.
  0330: 00 10 00 30 00 00 00 00 00 00 00 00 00 00 00 00  ...0..........=
=2E.
  0340: 00 10 00 31 00 00 00 00 00 00 00 00 00 00 00 00  ...1..........=
=2E.
  0350: 00 10 00 32 00 00 00 00 00 00 00 00 00 00 00 00  ...2..........=
=2E.
  0360: 00 10 00 33 00 00 00 00 00 00 00 00 00 00 00 00  ...3..........=
=2E.
  0370: 00 10 00 34 00 00 00 00 00 00 00 00 00 00 00 00  ...4..........=
=2E.
  0380: 00 10 00 35 00 00 00 00 00 00 00 00 00 00 00 00  ...5..........=
=2E.
  0390: 00 10 00 36 00 00 00 00 00 00 00 00 00 00 00 00  ...6..........=
=2E.
  03A0: 00 10 00 37 00 00 00 00 00 00 00 00 00 00 00 00  ...7..........=
=2E.
  03B0: 00 10 00 38 00 00 00 00 00 00 00 00 00 00 00 00  ...8..........=
=2E.
  03C0: 00 10 00 39 00 00 00 00 00 00 00 00 00 00 00 00  ...9..........=
=2E.
  03D0: 00 10 00 3A 00 00 00 00 00 00 00 00 00 00 00 00  ...:..........=
=2E.
  03E0: 00 10 00 3B 00 00 00 00 00 00 00 00 00 00 00 00  ...;..........=
=2E.
  03F0: 00 10 00 3C 00 00 00 00 00 00 00 00 00 00 00 00  ...<..........=
=2E.
  0400: 00 10 00 3D 00 00 00 00 00 00 00 00 00 00 00 00  ...=3D........=
=2E...
  0410: 00 10 00 3E 00 00 00 00 00 00 00 00 00 00 00 00  ...>..........=
=2E.
  0420: 00 10 00 3F 00 00 00 00 00 00 00 00 00 00 00 00  ...?..........=
=2E.
  0430: 01 28 00 00 00 00 00 00 00 00 00 00 00 00 00 00  .(............=
=2E.
  0440: 00 00 00 E0 00 00 00 00 00 00 00 00 01 00 00 00  ..............=
=2E.
  0450: 00 00 00 00 00 00 00 00 01 28 00 00 00 00 00 00  .........(....=
=2E.
  0460: 00 00 00 E0 00 00 00 00 00 00 00 20 00 00 00 00  ........... ..=
=2E.
  0470: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ..............=
=2E.
  0480: 01 28 00 00 00 00 00 00 00 00 00 00 01 00 00 00  .(............=
=2E.
  0490: 00 00 00 20 01 00 00 00 00 00 00 00 01 00 00 00  ... ..........=
=2E.
  04A0: 00 00 00 00 00 00 00 00 01 28 01 00 00 00 00 00  .........(....=
=2E.
  04B0: 00 00 00 20 02 00 00 00 00 00 00 00 02 00 00 00  ... ..........=
=2E.
  04C0: 00 00 00 00 01 00 00 00 00 00 00 00 00 00 00 00  ..............=
=2E.
  04D0: 01 28 00 00 00 00 00 00 00 00 00 20 04 00 00 00  .(......... ..=
=2E.
  04E0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ..............=
=2E.
  04F0: 00 00 00 00 00 00 00 00 01 28 00 00 00 00 00 00  .........(....=
=2E.
  0500: 00 00 00 20 04 00 00 00 00 00 00 00 00 00 00 00  ... ..........=
=2E.
  0510: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ..............=
=2E.
  0520: 01 28 00 00 00 00 00 00 00 00 00 20 04 00 00 00  .(......... ..=
=2E.
  0530: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ..............=
=2E.
  0540: 00 00 00 00 00 00 00 00 01 28 00 00 00 00 00 00  .........(....=
=2E.
  0550: 00 00 00 20 04 00 00 00 00 00 00 00 00 00 00 00  ... ..........=
=2E.
  0560: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ..............=
=2E.


