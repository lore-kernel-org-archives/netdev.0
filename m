From: Pedro Fortuna <pedro.fortuna@gmail.com>
Subject: Re: filtering packtes before OS takes care about them
Date: Mon, 7 Mar 2005 02:46:00 +0000
Message-ID: <db95d40c050306184626888a9f@mail.gmail.com>
References: <09766A6E64A068419B362367800D50C0B58A17@moritz.faps.uni-erlangen.de>
	 <7bca1cb50502281209798e8a00@mail.gmail.com>
	 <db95d40c0503050608e1e98d9@mail.gmail.com>
	 <7bca1cb505030510586aeb96c1@mail.gmail.com>
	 <db95d40c050305113668c3ff07@mail.gmail.com>
	 <7bca1cb50503051729e3273d3@mail.gmail.com>
Reply-To: Pedro Fortuna <pedro.fortuna@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Asim Shankar <asimshankar@gmail.com>
In-Reply-To: <7bca1cb50503051729e3273d3@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello Asim,

Sorry to bother you again, but I run into some problems doing the
tunneling stuff and maybe you or somebody else can give some clues.

Based on your code I've coded two small kernel modules that used
packet_type function handlers to basically do the following:
The mod1@PC1 intercepts every FTP packet sent from PC1 to PC2,
replacing the ethertype (0x800) in the ethernet header for a new
unknown ethertype (0x801). The packets are then sent to PC2 in which
mod2 is running. Mod2@PC2 intercepts the packet and replaces back the
ethertype to the standard (0x800). The packet is then delivered to the
FTP application which answers back to PC1 with unchanged frames. The
PC's are linked with a cross-over ethernet cable (no switch/bridge
interference)

I've run ethereal in both hosts while I test the modules and this was
what I observed:
- In PC1, I was able to observe ethernet frames with 0x801: I shouln't
see this because the ethertype change should be the _last_ thing just
before the packet is passed to the network driver. From this I
conclued that my packet_type function is not registed as the last
function to handle packets (i.e. might be the first).
- In PC2, I was able to observe the ethernet frames (sent by PC1) with
0x800: This is good, because it means that mod2 was able to change the
ethertype 0x801 to 0x800 before (I presume) any other function handled
the packet.
- The problem is that PC2 never answers to the FTP Syn packets :-(
With mod1 and mod2 unloaded I was able to fully use FTP, so I know it
is (almost certainly) a problem with mod2.

Here it is a small portion of mod2's code:
static int __init init(void)
{
        my_packet_type.type = htons(ETH_P_ALL);
        my_packet_type.func = packet_rcv;
        my_packet_type.dev = NULL;
        dev_add_pack(&my_packet_type);
}

static int packet_rcv(struct sk_buff *skb, struct net_device *dev,
struct packet_type *pt)
{
        struct ethhdr *eh  = eth_hdr(skb);
        if (eh->h_proto == htons(0x801)) { //reverse operation
                revopcount++;
                eh->h_proto=htons(0x800);
                printk(KERN_ERR "packet_type_test: reverse-op!
revopcount=%d\n",revopcount);
        }
        kfree_skb(skb);
        return 0;
}

As you can see from the code excerpt, this is a very simple module, so
I guess Im missing some very basic piece of the puzzle :\
I think the problem might be related with the position of my
packet_type function in the packet_type functions list i.e. the
ip_rcv() receiving the 0x801 version (not the 0x800) and dropping the
FTP syn packet.

Any tips are appreciated,
-Pedro Fortuna


On Sat, 5 Mar 2005 19:29:34 -0600, Asim Shankar <asimshankar@gmail.com> wrote:
> Hi Pedro,
> 
> Yeah, it should be able to cover all outgoing packets as well.
> Basically, all struct packet_type{}s with the type field set to
> htons(ETH_P_ALL) are also called on outgoing packets (see
> dev_queue_xmit_nit() called by dev_queue_xmit() in net/core/dev.c)
> 
> Though as I mentioned earlier, I'm not sure if this will *always*
> happen (i.e., if outgoing packets *always* go through
> dev_queue_xmit()). Someone more knowledgeable may have to answer that.
> 
> Best of luck and let me know if you have any trouble,
> Regards,
> 
> -- Asim
> 
> On Sat, 5 Mar 2005 19:36:38 +0000, Pedro Fortuna
> <pedro.fortuna@gmail.com> wrote:
> > Hello Asim,
> > I tried again but this time in Fedora Core 3 (kernel 2.6.10-1.760_FC3)
> > and it went flawlessly.
> > I have a look into your example and also into the Phrack article you
> > mentioned and now I'm ready to begin some tests towards what I want to
> > implement.
> >
> > It's absolutly clear you can fetch (and modify) packets before they
> > are delivered to the TCP/IP stack with a custom packet_type function,
> > but is it also possible to intercept just before they are passed to
> > the network driver?
> >
> > Thanks,
> > -Pedro Fortuna
> >
> >
> > On Sat, 5 Mar 2005 12:58:23 -0600, Asim Shankar <asimshankar@gmail.com> wrote:
> > > > I wasnt able to compile your packet_type_test.c :
> > > > all I got was a huge list of errors
> > > > and warnings, and no .o compiled in the end.
> > >
> > > Can you send the specific errors you got?
> > > And is the kernel sources present in
> > > /lib/modules/`uname -r`/build?
> > >
> > > Regards,
> > >
> > > -- Asim
> > >
> >
>
