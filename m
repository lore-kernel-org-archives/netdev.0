From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: 32 core net-next stack/netfilter "scaling"
Date: Mon, 26 Jan 2009 15:14:02 -0800
Message-ID: <20090126151402.571b12c2@extreme>
References: <497E361B.30909@hp.com>
	<497E42F4.7080201@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rick Jones <rick.jones2@hp.com>,
	Linux Network Development list <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <497E42F4.7080201@cosmosbay.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 27 Jan 2009 00:10:44 +0100
Eric Dumazet <dada1@cosmosbay.com> wrote:

> Rick Jones a =C3=A9crit :
> > Folks -
> >=20
> > Under:
> >=20
> > ftp://ftp.netperf.org/iptable_scaling
> >=20
> > can be found netperf results and Caliper profiles for three scenari=
os on
> > a 32-core, 1.6 GHz 'Montecito' rx8640 system.  An rx8640 is what HP=
 call
> > a "cell based" system in that it is comprised of "cell boards" on w=
hich
> > reside CPU and memory resources.  In this case there are four cell
> > boards, each with 4, dual-core Montecito processors and 1/4 of the
> > overall RAM.  The system was configured with a mix of cell-local an=
d
> > global interleaved memory, where the global interleave is on a cach=
eline
> > (128 byte) boundary (IIRC).  Total RAM in the system is 256 GB.  Th=
e
> > cells are joined via cross-bar connections. (numactl --hardware out=
put
> > is available under the URL above)
> >=20
> > There was an "I/O expander" connected to the system.  This meant th=
ere
> > were as many distinct PCI-X domains as there were cells, and every =
cell
> > had a "local" set of PCI-X slots.
> >=20
> > Into those slots I placed four HP AD385A PCI-X 10Gbit Ethernet NICs=
 -
> > aka Neterion XFrame IIs.  These were then connected to an HP ProCur=
ve
> > 5806 switch, which was in turn connected to three, 4P/16C, 2.3 GHz =
HP
> > DL585 G5s, each of which had a pair of HP AD386A PCIe 10Gbit Ethern=
et
> > NICs (Aka Chelsio T3C-based).  They were running RHEL 5.2 I think. =
 Each
> > NIC was in either a PCI-X 2.0 266 MHz slot (rx8640) or a PCIe 1.mum=
ble
> > x8 slot (DL585 G5)
> >=20
> > The kernel is from DaveM's net-next tree ca last week, multiq enabl=
ed.=20
> > The s2io driver is Neterion's out-of-tree version 2.0.36.15914 to g=
et
> > multiq support.  It was loaded into the kernel via:
> >=20
> > insmod ./s2io.ko tx_steering_type=3D3 tx_fifo_num=3D8
> >=20
> > There were then 8 tx queues and 8 rx queues per interface in the
> > rx8640.  The "setaffinity.txt" script was used to set the IRQ affin=
ities
> > to cores "closest" to the physical NIC. In all three tests all 32 c=
ores
> > went to 100% utilization. At least for all incense and porpoises. (=
there
> > was some occasional idle reported by top on the full_iptables run)
> >=20
> > A set of 64, concurrent "burst mode" netperf omni RR tests (tcp) wi=
th a
> > burst mode of 17 were run (ie 17 "transactions" outstanding on a
> > connection at one time,) with TCP_NODELAY set and the results gathe=
red,
> > along with a set of Caliper profiles.  The script used to launch th=
ese
> > can be found in "runemomniagg2.sh.txt under the URL above.
> >=20
> > I picked an "RR" test to maximize the trips up and down the stack w=
hile
> > minimizing the bandwidth consumed.
> >=20
> > I picked a burst size of 16 because that was sufficient to saturate=
 a
> > single core on the rx8640.
> >=20
> > I picked 64 concurrent netperfs because I wanted to make sure I had
> > enough concurrent connections to get spread across all the cores/qu=
eues
> > by the algorithms in place.
> >=20
> > I picked the combination of 64 and 16 rather than say 1024 and 0 (o=
ne
> > tran at a time) because I didn't want to run a context switching
> > benchmark :)
> >=20
> > The rx8640 was picked because it was available and I was confident =
it
> > was not going to have any hardware scaling issues getting in the wa=
y.  I
> > wanted to see SW issues, not HW issues. I am ass-u-me-ing the rx864=
0 is
> > a reasonable analog for any "decent or better scaling" 32 core hard=
ware
> > and that while there are ia64-specific routines present in the prof=
iles,
> > they are there for platform-independent reasons.
> >=20
> > The no_iptables/ data was run after a fresh boot, with no iptables
> > commands run and so no iptables related modules loaded into the ker=
nel.
> >=20
> > The empty_iptables/ data was run after an "iptables --list" command
> > which loaded one or two modules into the kernel.
> >=20
> > The full_iptables/ data was run after an "iptables-restore" command
> > pointed at full_iptables/iptables.txt  which was created from what =
RH
> > creates by default when one enables firewall via their installer, w=
ith a
> > port range added by me to allow pretty much anything netperf would =
ask.=20
> > As such, while it does excercise netfilter functionality, I cannot =
make
> > any claims as to its "real world" applicability.  (while the firewa=
ll
> > settings came from an RH setup, FWIW, the base bits running on the
> > rx8640 are Debian Lenny, with the net-next kernel on top)
> >=20
> > The "cycles" profile is able to grab flat profile hits while interr=
upts
> > are disabled so it can see stuff happening while interrupts are
> > disabled.  The "scgprof" profile is an attempt to get some call gra=
phs -
> > it does not have visibility into code running with interrupts disab=
led.=20
> > The "cache" profile is a profile that looks to get some cache miss
> > information.
> >=20
> > So, having said all that, details can be found under the previously
> > mentioned URL.  Some quick highlights:
> >=20
> > no_iptables - ~22000 transactions/s/netperf.  Top of the cycles pro=
file
> > looks like:
> >=20
> > Function Summary
> > -------------------------------------------------------------------=
----
> > % Total
> >      IP  Cumulat             IP
> > Samples    % of         Samples
> >  (ETB)     Total         (ETB)   Function                          =
=46ile
> > -------------------------------------------------------------------=
----
> >    5.70     5.70         37772   s2io.ko::tx_intr_handler
> >    5.14    10.84         34012   vmlinux::__ia64_readq
> >    4.88    15.72         32285   s2io.ko::s2io_msix_ring_handle
> >    4.63    20.34         30625   s2io.ko::rx_intr_handler
> >    4.60    24.94         30429   s2io.ko::s2io_xmit
> >    3.85    28.79         25488   s2io.ko::s2io_poll_msix
> >    2.87    31.65         18987   vmlinux::dev_queue_xmit
> >    2.51    34.16         16620   vmlinux::tcp_sendmsg
> >    2.51    36.67         16588   vmlinux::tcp_ack
> >    2.15    38.82         14221   vmlinux::__inet_lookup_established
> >    2.10    40.92         13937   vmlinux::ia64_spinlock_contention
> >=20
> > empty_iptables - ~12000 transactions/s/netperf.  Top of the cycles
> > profile looks like:
> >=20
> > Function Summary
> > -------------------------------------------------------------------=
----
> > % Total
> >      IP  Cumulat             IP
> > Samples    % of         Samples
> >  (ETB)     Total         (ETB)   Function                          =
=46ile
> > -------------------------------------------------------------------=
----
> >   26.38    26.38        137458   vmlinux::_read_lock_bh
> >   10.63    37.01         55388   vmlinux::local_bh_enable_ip
> >    3.42    40.43         17812   s2io.ko::tx_intr_handler
> >    3.01    43.44         15691   ip_tables.ko::ipt_do_table
> >    2.90    46.34         15100   vmlinux::__ia64_readq
> >    2.72    49.06         14179   s2io.ko::rx_intr_handler
> >    2.55    51.61         13288   s2io.ko::s2io_xmit
> >    1.98    53.59         10329   s2io.ko::s2io_msix_ring_handle
> >    1.75    55.34          9104   vmlinux::dev_queue_xmit
> >    1.64    56.98          8546   s2io.ko::s2io_poll_msix
> >    1.52    58.50          7943   vmlinux::sock_wfree
> >    1.40    59.91          7302   vmlinux::tcp_ack
> >=20
> > full_iptables - some test instances didn't complete, I think they g=
ot
> > starved. Of those which did complete, their performance ranged all =
the
> > way from 330 to 3100 transactions/s/netperf.  Top of the cycles pro=
file
> > looks like:
> >=20
> > Function Summary
> > -------------------------------------------------------------------=
----
> > % Total
> >      IP  Cumulat             IP
> > Samples    % of         Samples
> >  (ETB)     Total         (ETB)   Function                          =
=46ile
> > -------------------------------------------------------------------=
----
> >   64.71    64.71        582171   vmlinux::_write_lock_bh
> >   18.43    83.14        165822   vmlinux::ia64_spinlock_contention
> >    2.86    85.99         25709   nf_conntrack.ko::init_module
> >    2.36    88.35         21194   nf_conntrack.ko::tcp_packet
> >    1.78    90.13         16009   vmlinux::_spin_lock_bh
> >    1.20    91.33         10810   nf_conntrack.ko::nf_conntrack_in
> >    1.20    92.52         10755   vmlinux::nf_iterate
> >    1.09    93.62          9833   vmlinux::default_idle
> >    0.26    93.88          2331   vmlinux::__ia64_readq
> >    0.25    94.12          2213   vmlinux::__interrupt
> >    0.24    94.37          2203   s2io.ko::tx_intr_handler
> >=20
> > Suggestions as to things to look at/with and/or patches to try are
> > welcome.  I should have the HW available to me for at least a littl=
e
> > while, but not indefinitely.
> >=20
> > rick jones
>=20
> Hi Rick, nice hardware you have :)
>=20
> Stephen had a patch to nuke read_lock() from iptables, using RCU and =
seqlocks.
> I hit this contention point even with low cost hardware, and quite st=
andard application.
>=20
> I pinged him few days ago to try to finish the job with him, but it s=
eems Stephen
> is busy at the moment.
>=20
> Then conntrack (tcp sessions) is awfull, since it uses a single rwloc=
k_t tcp_lock
>  that must be write_locked() for basically every handled tcp frame...
>=20
> How long is "not indefinitely" ?=20

Hey, I just got back from Linux Conf Au, haven't had time to catch up y=
et.
It is on my list, after dealing with the other work related stuff.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
