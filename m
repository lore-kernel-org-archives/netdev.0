From: Christoph Raisch <RAISCH@de.ibm.com>
Subject: Re: [PATCH 2/2] ehea: Receive SKB Aggregation
Date: Mon, 4 Jun 2007 14:09:27 +0200
Message-ID: <OF83D042D3.CAC47E54-ONC12572F0.0041526E-C12572F0.0042A414@de.ibm.com>
References: <20070531093703.373995b2@freepuppy>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Jan-Bernd Themann <themann@de.ibm.com>,
	Jeff Garzik <jeff@garzik.org>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-ppc" <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	Stefan Roscher <ossrosch@linux.vnet.ibm.com>,
	ossthema@linux.vnet.ibm.com, Thomas Q Klein <tklein@de.ibm.com>,
	tklein@linux.ibm.com
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754492AbXFDMnG@vger.kernel.org>
In-Reply-To: <20070531093703.373995b2@freepuppy>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Stephen Hemminger  wrote on 31.05.2007 18:37:03:

>
> >
> >
> > +static int try_get_ip_tcp_hdr(struct ehea_cqe *cqe, struct sk_buff
*skb,
> > +               struct iphdr **iph, struct tcphdr **tcph)
> > +{
> > +   int ip_len;
> > +
> > +   /* non tcp/udp packets */
> > +   if (!cqe->header_length)
> > +      return -1;
> > +
> > +   /* non tcp packet */
> > +   *iph = (struct iphdr *)(skb->data);
>
> Why the indirection, copying of headers..
This interacts with the header split function in the hardware.
>
> > +   if ((*iph)->protocol != IPPROTO_TCP)
> > +      return -1;
> > +
> > +   ip_len = (u8)((*iph)->ihl);
> > +   ip_len <<= 2;
> > +   *tcph = (struct tcphdr *)(((u64)*iph) + ip_len);
> > +
> > +   return 0;
> > +}
> > +
> >
>
> This code seems to be duplicating a lot  (but not all) of the TCP/IP
> input path validation checks. This is a security problem if nothing
else...
>
We should only do aggregation in the driver if this really is a TCP header,
otherwise things will get worse.
You're right, we should at least check that tcph is within the received
frame.

> Also, how do you prevent DoS attacks from hostile TCP senders that send
> huge number of back to back frames?

Actually a huge number of back to back frames is what we would want to
receive
at 10 gbit ;-)
How is it possible to figure out if this is what you want or just DoS?
It doesn't change anything compared to a non LRO driver, we process a
certain
maximum amount of frames before waiting for the next interrupt,
the packet filters/DoS should still see all traffic (which is above the
driver).
Any suggestions how to handle this better/different?

>
> --
> Stephen Hemminger

Gruss / Regards
Christoph Raisch
