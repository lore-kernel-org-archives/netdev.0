From: jamal <hadi@cyberus.ca>
Subject: Re: user space multicast routing interface
Date: 25 Jan 2004 14:35:24 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1075059324.1745.95.camel@jzny.localdomain>
References: <4013FEC9.1070900@diac24.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Lamparter <equinox@diac24.net>
In-Reply-To: <4013FEC9.1070900@diac24.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

consider using a BPF filter to capture only IGMP.
If you google nicely she may tell you something useful.

cheers,
jamal

On Sun, 2004-01-25 at 12:37, David Lamparter wrote:
> Hi,
> 
> [...skip down if you don't like long "sorry for mailing" mails ;)]
> 
> first of all, please excuse me mailing to netdev for a not directly
> kernel related Linux networking question - i didn't find any other place
> where i could ask...
> 
> I recently started playing around with multicast routing for educational
> purposes; multicast client software was easy to write, ran well and
> there were lots of docs about setsockopts etc.
> 
> Continuing on my way, I'm trying to write a simple IGMP querier now, but
> even getting started turns out to be pretty difficult here, almost no
> docs exist (well, the FreeBSD manpage...). I tried everything coming to
> my mind, but i wasn't even able to get to receiving all IGMP packets on
> an interface.
> 
> [...stop skipping here]
> 
> so, 2 questions:
> * what sockopts are neccessary to get all IGMP packets (all multicast
> groups) on a raw socket? (MRT_INIT / MRT_ADD_VIF should do it, but it
> doesn't work)
> * is it possible to bind VIFs to interface indices? in ipmr.c / struct
> vifctl there is no ifindex parameter (real interface, not vif)
> 
> as you can see from the 2nd question, i at least tried reading the
> kernel source (2.6.1), but i don't know the stack so its difficult to
> understand...
> 
> David Lamparter
> 
> 
> 
> Appended: testing code for IGMP
> 
> no error messages on 2.6.1, interface has
> <BROADCAST,MULTICAST,ALLMULTI,UP> flags while code is running, vif shows
> up under /proc/net/ip_mr_vif:
> Interface      BytesIn  PktsIn  BytesOut PktsOut Flags Local    Remote
>   1 eth0              0       0         0       0 08000 160216AC 00000000
> 
> <cut includes for space issues>
> 
> #define E(x) if (x) printf ("error doing %s: %d [%s]\n", \
>          #x, errno, strerror (errno));
> int main(int argc, char **argv)
> {
>          int mrouter_s4; int p = 1; struct vifctl vc;
> 
>          mrouter_s4 = socket(AF_INET, SOCK_RAW, IPPROTO_IGMP);
>          E(setsockopt(mrouter_s4, IPPROTO_IP, MRT_INIT,
>                  (void *)&p, sizeof(p)));
> 
>          memset(&vc, 0, sizeof(vc));
>          vc.vifc_vifi = vc.vifc_threshold = 1;
>          vc.vifc_rate_limit = 4096;
>          vc.vifc_lcl_addr.s_addr = inet_addr(argv[1]);
>          E(setsockopt(mrouter_s4, IPPROTO_IP, MRT_ADD_VIF,
>                  (void *)&vc, sizeof(vc)));
> 
>          while(1) {
>                  char buf[4096]; struct sockaddr_in sender;
>                  socklen_t sendsize = sizeof(sender);
>                  int size = recvfrom(mrouter_s4, buf, 4096, 0,
>                          (struct sockaddr *) &sender, &sendsize);
>                  printf ("got %d from %s\n", size,
>                          inet_ntoa(sender.sin_addr));
>          }
> }
> 
> 
> 
> 
> 
> 
