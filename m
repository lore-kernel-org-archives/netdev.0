From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: dev->destructor
Date: Thu, 1 May 2003 14:51:11 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030501175111.GF3387@conectiva.com.br>
References: <20030501.000058.39187964.davem@redhat.com> <20030501120815.25BE22C155@lists.samba.org> <20030501.040935.68070653.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rusty@rustcorp.com.au, kuznet@ms2.inr.ac.ru, shemminger@osdl.org,
   netdev@oss.sgi.com, wa@almesberger.net
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030501.040935.68070653.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Thu, May 01, 2003 at 04:09:35AM -0700, David S. Miller escreveu:
>    From: Rusty Russell <rusty@rustcorp.com.au>
>    Date: Thu, 01 May 2003 22:01:19 +1000
>    
>    There are 70 calls to dev_hold() in the kernel.  The vast majority of
>    them already have a reference, they just want another one: dev_hold()
>    can do __module_get().
> 
> Rusty, this is precisely the what Alexey and myself want to avoid.  On
> the surface, it looks fine, only 70 dev_get's in the kernel right?
> But think further...
> 
> So you propose to add this kind of thing for every ARP entry, every
> route cache entry, every IPSEC policy, every socket, every struct
> sock, every networking dynamic object ever created?

ALERT: brainstorming and expecting for comments from the people who knows this
better.

Well, I think that because there are a graph of relationships here we perhaps
can be safe by protecting just some of the higher level objects (e.g. struct
sock, struct socket, struct net_device) while leaving some other lower level
objects managed by those higher level ones, e.g. struct sk_buff managed by
struct sock.

This came to me while discussing the struct socket and struct sock module
infrastructure with Max, specifically when net family modules (e.g. AF_INET)
doesn't requires protecting for each and every struct socket created, as the
protocol modules (e.g.: udp, raw, tcp) have to somehow register with the net
family module and by just using one exported function (register_protocol type
functions: register_pppox_proto, bt_sock_register, register_8022_client,
register_snap_client, llc_sap_open, etc) makes the net family module/lower
level protocol protected.

So we need to have a graph of these relationships to see what we have to
protect at a higher level, reducing the overhead of otherwise having to call
try_module_get/__module_get & module_put on _all_ objects creation/use.

- Arnaldo
