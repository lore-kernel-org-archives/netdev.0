From: bert hubert <ahu@ds9a.nl>
Subject: analysis of TCP window size issues still around - several reports / SACK involved?
Date: Tue, 6 Jul 2004 11:35:03 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040706093503.GA8147@outpost.ds9a.nl>
References: <32886.63.170.215.71.1088564087.squirrel@www.osdl.org> <20040629222751.392f0a82.davem@redhat.com> <20040630152750.2d01ca51@dell_ss3.pdx.osdl.net> <20040630153049.3ca25b76.davem@redhat.com> <20040701133738.301b9e46@dell_ss3.pdx.osdl.net> <20040701140406.62dfbc2a.davem@redhat.com> <20040702013225.GA24707@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>,
        "linux-kernel @ vger. kernel. org Stephen Hemminger" <shemminger@osdl.org>,
        netdev@oss.sgi.com, alessandro.suardi@oracle.com, phyprabab@yahoo.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Content-Disposition: inline
In-Reply-To: <20040702013225.GA24707@conectiva.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jul 01, 2004 at 10:32:25PM -0300, Arnaldo Carvalho de Melo wrote:

> > > Rather than using *tcp_prot.memory_pressure, just go back to looking at
> > > tcp_memory_pressure.
> > 
> > Hehe, applied thanks Stephen.

People,

There are still persistent reports of TCP problems, even after patching away
the memory_pressure pointer problem. From one trace I've seen, by Alessandro
Suardi, but I lack the SACK knowledge to fully interpret these traces:

22:42:40.890025 192.168.1.6.32843 > 204.152.189.116.http: S 1994994484:1994994484(0) win 5840 <mss 1460,sackOK,timestamp 4294940315 0,nop,wscale 7> (DF)
22:42:41.143063 204.152.189.116.http > 192.168.1.6.32843: S 1404108869:1404108869(0) ack 1994994485 win 5792 <mss 1452,sackOK,timestamp 3383469176 4294940315,nop,wscale 0> (DF)
22:42:41.143123 192.168.1.6.32843 > 204.152.189.116.http: . ack 1 win 45 <nop,nop,timestamp 4294940568 3383469176> (DF)

Alessandro's machine does perform window scaling, tcpdump however does not
understand that and neglects to multiply 45 by 2^7 (=5760). Kernel.org does do
wscale, but defaults to 2^0.

22:42:41.143362 192.168.1.6.32843 > 204.152.189.116.http: P 1:421(420) ack 1 win 45 <nop,nop,timestamp 4294940568 3383469176> (DF)

Alessandro's machine sends a GET request.

22:42:41.147669 204.152.189.116.http > 192.168.1.6.32843: S 1404108869:1404108869(0) ack 1994994485 win 5792 <mss 1452,sackOK,timestamp 3383469180 4294940315,nop,wscale 0> (DF)

www.kernel.org acts like it did not see our ACK.

22:42:41.147723 192.168.1.6.32843 > 204.152.189.116.http: . ack 1 win 45 <nop,nop,timestamp 4294940572 3383469180,nop,nop,sack sack 1 {0:1} > (DF)

Allessandro's machine sends a selective ACK - could have gotten away with a
regular one I'd think?

22:42:41.408763 204.152.189.116.http > 192.168.1.6.32843: . ack 421 win 6432 <nop,nop,timestamp 3383469440 4294940568> (DF)

www.kernel.org acks the GET, but from then on does not send anything.

After a minute, Alessandro gets bored and presses STOP in Mozilla:

22:43:41.051537 192.168.1.6.32843 > 204.152.189.116.http: F 421:421(0) ack 1 win 45 <nop,nop,timestamp 33189 3383469440> (DF)

k.o acks this FIN, but also sends a selective ack:

22:43:41.304371 204.152.189.116.http > 192.168.1.6.32843: . ack 422 win 6432 <nop,nop,timestamp 3383529343 33189,nop,nop,sack sack 1 {421:422} > (DF)

Here are the underlying reports:

http://lkml.org/lkml/2004/7/4/116 (Alessandro Suardi)
	The _only_ site I found I can browse without disabling TCP
	  window scaling is http://www.google.it.

	tcpdump at: http://xoomer.virgilio.it/incident/tcpdump.out 

http://lkml.org/lkml/2004/7/5/105 (Phy Prabab)
	Concerning my issue with ftp'ing from remote sites,
	using these sysctl's I was able to get the performance
	back:

	net.ipv4.tcp_default_win_scale=0
	net.ipv4.tcp_moderate_rcvbuf=0

	2.6.7-bk18 w/out sysctls:
	2573621 bytes received in 2e+02 seconds (12 Kbytes/s)

	2.6.7-bk18 w/sysctls:
	2573621 bytes received in 0.69 seconds (3.6e+03
	Kbytes/s)

These both refer to bk after the *tcp_prot.memory_pressure patch was
applied.

Thanks for your attention.

-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
