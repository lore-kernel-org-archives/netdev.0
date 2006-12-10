From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [NETLINK]: Schedule removal of old macros exported to userspace
Date: Sun, 10 Dec 2006 13:15:05 +0100
Message-ID: <20061210121505.GQ8693@postel.suug.ch>
References: <20061208.164345.71119524.davem@davemloft.net> <20061209.134552.71105673.davem@davemloft.net> <20061209232805.GP8693@postel.suug.ch> <200612101109.34149.stefan@loplof.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, drow@false.org, 	dwmw2@infradead.org, joseph@codesourcery.com, netdev@vger.kernel.org, 	libc-alpha@sourceware.org, akpm@osdl.org
Return-path: <libc-alpha-return-19654-glibc-alpha=m.gmane.org@sourceware.org>
To: Stefan Rompf <stefan@loplof.de>
Content-Disposition: inline
In-Reply-To: <200612101109.34149.stefan@loplof.de>
List-Unsubscribe: <mailto:libc-alpha-unsubscribe-glibc-alpha=m.gmane.org@sourceware.org>
List-Subscribe: <mailto:libc-alpha-subscribe@sourceware.org>
List-Archive: <http://sourceware.org/ml/libc-alpha/>
List-Post: <mailto:libc-alpha@sourceware.org>
List-Help: <mailto:libc-alpha-help@sourceware.org>, <http://sourceware.org/ml/#faqs>
Sender: libc-alpha-owner@sourceware.org
List-Id: netdev.vger.kernel.org

* Stefan Rompf <stefan@loplof.de> 2006-12-10 11:11
> Please send me the list of bugs you've spotted. Of course I want to fix them.

Sure...

static void nl_handlemsg(struct nlmsghdr *msg, unsigned int len) {
  if (len < sizeof(*msg)) return;

  while(NLMSG_OK(msg,len)) {
    if (nlcb_run &&
	nlcb_pid == msg->nlmsg_pid &&
	nlcb_seq == msg->nlmsg_seq) {
      nlcb_function(msg, nlcb_args);

Missing check for sufficient payload, family specific header
and attributes are accessed directly, you've only made sure
a netlink message header is present so far.

static void copy_ifdata(struct nlmsghdr *msg, void **args) {
  struct dhcp_interface *dhcpif = args[0];
  struct ifinfomsg *ifinfo = NLMSG_DATA(msg);
  struct rtattr *rta = IFLA_RTA(ifinfo);
  int len = msg->nlmsg_len - NLMSG_LENGTH(sizeof(*ifinfo));

This is also wrong, it's lacking NLMSG_ALIGN() to consider
the padding between the family specific header and the
attributes, you'd assume the padding to be attributes and
access memory beyond the message.

  if (msg->nlmsg_type != RTM_NEWLINK) return;
  if (dhcpif->ifidx) return;

  for(; RTA_OK(rta, len); rta = RTA_NEXT(rta, len)) {
    switch(rta->rta_type) {
    case IFLA_IFNAME:
      if (!strcmp(dhcpif->ifname, (char *)RTA_DATA(rta)))

Payload length not checked or a horrible crash if payload is
not NUL terminated.

	dhcpif->ifidx = ifinfo->ifi_index;
      break;
    case IFLA_ADDRESS:
      memcpy(dhcpif->ifhwaddr, RTA_DATA(rta), 6); /* FIXME */
      break;

Even worse, IFLA_ADDRESS may be of arbitary length up to
MAX_ADDR_LEN.

Basically the slightest malformed netlink message or even semantic
changes within the legal boundries will simply crash your application.

> My main problem with netlink was missing or wrong documentation (and yes, I 
> know it's much easier writing code than writing docs, especially if OSS 
> development is just a hobby).

Before accusing it would have been nice to do some research and you may
have found a lot of netlink documentation inside the libnl documentation.

> F.e. until 2.6.19 it has not been possible to 
> query one ifi_index with RTM_GETLINK even though rfc3549 specified this 
> operation.

It was available through wireless extensions and there is also a
AF_INET6 specific variation providing even more details. It wasn't
implemented for AF_UNSPEC before because, I believe, Alexey was just
too lazy to do it and used the bsd interface for this purpose in
iproute2 which is based on ioctl :-) I made rtnl_getlink() available
because I agree its useful but you've been preaching compatibility so
much I really can't imagine it being useful to you as it would make
your appliaction depend on >= 2.6.19.

> Instead, the application had to dump all interfaces and filter the 
> record it is interested in. Stuff like this creates much more bugs than a 
> non-typesafe macro because it makes you think "Damn it's working now, never 
> touch that code again".

Right... Would also have been an option to use the perfectly documented
interface and save a lot of sweat: (From libnl documentation)

1) Retrieving information about available links

 // The first step is to retrieve a list of all available interfaces within
 // the kernel and put them into a cache.
 struct nl_cache *cache = rtnl_link_alloc_cache(nl_handle);

 // In a second step, a specific link may be looked up by either interface
 // index or interface name.
 struct rtnl_link *link = rtnl_link_get_by_name(cache, "lo");

 // rtnl_link_get_by_name() is the short version for translating the
 // interface name to an interface index first like this:
 int ifindex = rtnl_link_name2i(cache, "lo");
 struct rtnl_link *link = rtnl_link_get(cache, ifindex);

 // After successful usage, the object must be given back to the cache
 rtnl_link_put(link);

> Don't take this as an offense, I do value your work and will use libnl for 
> future projects, but I definitely do not share your opinion on how to deal 
> with ugly/obsolete userspace interfaces (even though this one is not 
> obsolete, because it is the only low level interface that exists at all).

That's just another inaccurate statement, libnl provides a low level interface
very similiar to libnetlink. On top of that it also implements the actual
netlink families to avoid every application having to write their own protocol
parser.

I see your point in libnl being expensive in terms of size, its modular design
would have made it trivial though to ship all but the core as loadable modules
and have embeded systems omit the modules it doesn't require such as traffic
control or even routing.
