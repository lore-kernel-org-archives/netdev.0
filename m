From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] [NET]: Fix deletion of local addresses only varying in prefix length
Date: Fri, 4 Mar 2005 14:14:19 +0100
Message-ID: <20050304131419.GE31837@postel.suug.ch>
References: <20050304012003.GA31837@postel.suug.ch> <E1D78DN-0002te-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1D78DN-0002te-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Herbert Xu <E1D78DN-0002te-00@gondolin.me.apana.org.au> 2005-03-04 19:31
> Thomas Graf <tgraf@suug.ch> wrote:
> > The deletion of local addresses via netlink doesn't take the
> > prefix length into account resulting in the deletion of
> > the address that was added first given multiple addresses
> > exist only varying in the prefix length.
> 
> This has the potential of breaking user-space scripts.  For example,
> this won't work anymore:
> 
> ip a a dev eth0 192.168.0.1/24
> ip a d dev eth0 192.168.0.1

Yes I know.

> 
> > tgr:axs ~ ip -4 addr show dev lo
> > 1: lo: <LOOPBACK,UP> mtu 16436 qdisc noqueue 
> >    inet 127.0.0.1/8 scope host lo
> >    inet 1.1.1.1/1 scope global lo
> >    inet 1.1.1.1/2 scope global lo
> 
> Do we really need to handle this case? If we do then would it be better
> to consider ifa_prefixlen only when there are multiple addresses present
> which match but differ by prefix length?

I do not agree but I might have a better idea. Let's change iproute2
to provide a prefixlength of 0 if no prefix was specified and only
compare the prefixes if it is non zero. This allows for accurate
deletion, no scripts will break (except for really really broken ones).
Given there are multiple matching addresses only varying in prefix
length and no prefix was specified the first one will get deleted but
this is well defined.

--- linux-2.6.11.orig/net/ipv4/devinet.c	2005-03-04 14:08:14.000000000 +0100
+++ linux-2.6.11/net/ipv4/devinet.c	2005-03-04 14:06:33.000000000 +0100
@@ -396,8 +396,10 @@
 	for (ifap = &in_dev->ifa_list; (ifa = *ifap) != NULL;
 	     ifap = &ifa->ifa_next) {
 		if ((rta[IFA_LOCAL - 1] &&
+		     ((ifm->ifa_prefixlen &&
+		      ifm->ifa_prefixlen != ifa->ifa_prefixlen) ||
 		     memcmp(RTA_DATA(rta[IFA_LOCAL - 1]),
-			    &ifa->ifa_local, 4)) ||
+			    &ifa->ifa_local, 4))) ||
 		    (rta[IFA_LABEL - 1] &&
 		     rtattr_strcmp(rta[IFA_LABEL - 1], ifa->ifa_label)) ||
 		    (rta[IFA_ADDRESS - 1] &&
