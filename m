From: Matt Domsch <Matt_Domsch@dell.com>
Subject: Re: [PATCH 2.6] dev.c: clear SIOCGIFHWADDR buffer if !dev->addr_len
Date: Sun, 31 Oct 2004 22:44:33 -0600
Message-ID: <20041101044433.GA18772@lists.us.dell.com>
References: <20041030013700.GA21540@lists.us.dell.com> <E1CNiOT-0008GU-00@gondolin.me.apana.org.au> <20041030030936.GA25102@lists.us.dell.com> <1099163419.1039.97.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1099163419.1039.97.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Oct 30, 2004 at 03:10:19PM -0400, jamal wrote:
> fix the net-snmp code. The addr_len is dependent on the device type.
> 6 is good for ethernet but may not equate for others.

I wish it were that simple.  The problem, in my mind, is that the
SIOCGIFHWADDR ioctl does not behave in 2.6 kernels as it has behaved
in previous kernels, and applications have no way to know this.  This
will lead to unexpected behaviour in many applications that (wrongly)
assume that the first 6 or more bytes of sa_data after ioctl() contain
valid data, unless told otherwise by a failure return value.

I took the liberty of unpacking all the sources to Fedora Core 3
development tree as of yesterday.  Of those I looked into the source
for, nearly all the packages that call SIOCGIFHWADDR make an
assumption on the number of bytes returned and the validity of such,
nearly none clear the request structure before calling it (so when
ioctl() returns 0 the app believes the data is correct).

anaconda-10.1.0.0/isys/getmacaddr.c:  if (ioctl(sock, SIOCGIFHWADDR, &ifr) < 0)
  BROKEN: clears ifr before ioctl, copies first 6 bytes of ifr.ifr_hwaddr.sa_data

busybox-1.00.rc1/networking/udhcp/socket.c:		if (ioctl(fd, SIOCGIFHWADDR, &ifr) == 0) {
  BROKEN: oesn't clear ifr before ioctl, copies first 6 bytes of
  ifr.ifr_hraddr.sa_data

busybox-1.00.rc1/networking/nameif.c:		if (ioctl(ctl_sk, SIOCGIFHWADDR, &ifr))
  BROKEN: doesn't clear ifr before ioctl, compares first ETH_ALEN bytes of
  ifr.ifr_hraddr.sa_data

busybox-1.00.rc1/networking/libiproute/iptunnel.c:	if (ioctl(fd, SIOCGIFHWADDR, &ifr)) {
  OK, only copies ifr.ifr_addr.sa_family

busybox-1.00.rc1/libbb/interface.c:	if (ioctl(skfd, SIOCGIFHWADDR, &ifr) < 0)
  BROKEN: doesn't clear ifr before ioctl, copies first 8 bytes of
  ifr.ifr_hraddr.sa_data

dhcp-0.10/common.c:	if (ioctl(skfd, SIOCGIFHWADDR, &if_hwaddr) < 0)
  OK, doesn't clear ifr before ioctl, copies first 6 bytes of
  ifr.ifr_hraddr.sa_data for sa_family ETHERNET, 0 for PPP.

dhcp-3.0.1/common/discover.c:		if (ioctl (sock, SIOCGIFHWADDR, &ifr) < 0)
  OK, doesn't clear ifr before ioctl, copies first 6 bytes of
  ifr.ifr_hraddr.sa_data for sa_family ETHERNET, considers PPP an
  error.

e2fsprogs-1.35/lib/uuid/gen_uuid.c:		if (ioctl(sd, SIOCGIFHWADDR, &ifr) < 0)
  BROKEN: doesn't clear ifr before ioctl, examines and copies first 6 bytes of
  ifr.ifr_hraddr.sa_data

gnome-netstatus-2.8.0/src/netstatus-iface.c:  if (ioctl (fd, SIOCGIFHWADDR, &if_req) < 0)
  BROKEN: doesn't clear ifr before ioctl, uses sa_family to determine action.

gnome-nettool-0.99.3/src/info.c:			ioctl (sockfd, SIOCGIFHWADDR, &ifrcopy);
  BROKEN: doesn't clear ifr before ioctl, prints first 6 bytes of sa_data

howl-0.9.6/src/lib/howl/Posix/posix_interface.c:	res = ioctl(sock, SIOCGIFHWADDR, &ifr);
howl-0.9.6/src/lib/howl/Posix/posix_interface.c:	res = ioctl(sock, SIOCGIFHWADDR, ifr);
  BROKEN: doesn't clear ifr before ioctl, copies first 6 bytes of sa_data (2 occurances)

net-snmp-5.1.2/snmplib/snmpv3.c:    if (ioctl(sock, SIOCGIFHWADDR, &request)) {
  BROKEN: does clear request, copies IFHWADDRLEN bytes of sa_data

net-snmp-5.1.2/agent/mibgroup/tunnel/tunnel.c:        if (ioctl(fd, SIOCGIFHWADDR, &ifrq) == 0)
  OK: doesn't clear request, doesn't look at sa_data, only sa_family.

net-snmp-5.1.2/agent/mibgroup/mibII/interfaces.c:        if (ioctl(fd, SIOCGIFHWADDR, &ifrq) < 0)
  BROKEN: doesn't clear ifrq, if ioctl fails it clears the 6
  destination bytes. If ioctl succeeds, it copies the first 6 bytes of sa_data.
  (this was the instance that made me realise the ioctl behaved differently)

net-snmp-5.1.2/agent/mibgroup/mibII/ipv6.c:            if (ioctl(s, SIOCGIFHWADDR, &ifr) < 0) {
  BROKEN: does clear ifrq, if ioctl fails it clears the 6 destination
  bytes. If ioctl succeeds, it copies the first 6 bytes of sa_data.


Exercise left to reader:
iproute2-2.6.9/ip/iptunnel.c:	err = ioctl(fd, SIOCGIFHWADDR, &ifr);
iproute2-2.6.9/misc/arpd.c:	if (ioctl(udp_sock, SIOCGIFHWADDR, &ifr))
iputils/rarpd.c:			if (ioctl(fd, SIOCGIFHWADDR, ifrp)) {
iputils/ifenslave.c:				rv = ioctl(skfd, SIOCGIFHWADDR, &if_hwaddr);
iputils/ifenslave.c:	if (ioctl(skfd, SIOCGIFHWADDR, &ifr) < 0)
irda-utils-0.9.16/irdaping/irdaping.c:        if (ioctl(self.fd, SIOCGIFHWADDR, &self.ifr) < 0 ) {
isdn4k-utils-CVS-2003-09-23/ipppd/sys-linux.c:	if (ioctl (sockfd, SIOCGIFHWADDR, &ifreq) < 0) {
isdn4k-utils-CVS-2003-09-23/libpcap-0.7.2/pcap-linux.c:	if (ioctl(fd, SIOCGIFHWADDR, &ifr) == -1) {
kudzu-1.1.95/kudzu.c:		if (ioctl(fd, SIOCGIFHWADDR, &ifr) < 0) goto next;
libgtop-2.8.0/sysdeps/linux/netload.c:	if (!ioctl (skfd, SIOCGIFHWADDR, &ifr)) {
ncpfs-2.2.4/ipx-1.0/ipx_cmd.c:		err = ioctl(fd_ipx, SIOCGIFHWADDR, &ifr);
net-tools-1.60/lib/interface.c:    if (ioctl(skfd, SIOCGIFHWADDR, &ifr) < 0)
net-tools-1.60/lib/interface.c.virtualname:    if (ioctl(skfd, SIOCGIFHWADDR, &ifr) < 0)
net-tools-1.60/lib/interface.c.cycle:    if (ioctl(skfd, SIOCGIFHWADDR, &ifr) < 0)
net-tools-1.60/lib/interface.c.siunits:    if (ioctl(skfd, SIOCGIFHWADDR, &ifr) < 0)
net-tools-1.60/arp.c:    if (ioctl(sockfd, SIOCGIFHWADDR, &ifr) < 0) {
net-tools-1.60/iptunnel.c:	err = ioctl(fd, SIOCGIFHWADDR, &ifr);
net-tools-1.60/nameif.c:	r = ioctl(ctl_sk, SIOCGIFHWADDR, &ifr);
net-tools-1.60/ether-wake.c:		if (ioctl(s, SIOCGIFHWADDR, &if_hwaddr) < 0) {
nmap-3.70/tcpip.cc:if (ioctl(sd, SIOCGIFHWADDR, &ifr) < 0 ) {
nmap-3.70/libpcap-possiblymodified/pcap-linux.c:	if (ioctl(fd, SIOCGIFHWADDR, &ifr) == -1) {
openswan-2.1.5/testing/attacks/espiv/ipsec_hack.c:	if (ioctl (listen_s, SIOCGIFHWADDR, &ifr) < 0) {
openswan-2.1.5/testing/attacks/espiv/ipsec_hack.c:	if (ioctl (send_s, SIOCGIFHWADDR, &ifr) < 0) {
ppp-2.4.2/pppd/plugins/rp-pppoe/plugin.c:	    if (ioctl(fd, SIOCGIFHWADDR, &ifr) < 0) {
ppp-2.4.2/pppd/plugins/rp-pppoe/if.c:	if (ioctl(fd, SIOCGIFHWADDR, &ifr) < 0) {
ppp-2.4.2/pppd/sys-linux.c:    if (ioctl (sock_fd, SIOCGIFHWADDR, &bestifreq) < 0) {
ppp-2.4.2/pppd/sys-linux.c:	ret = ioctl(sock_fd, SIOCGIFHWADDR, &ifreq);
ppp-2.4.2/pppd/sys-linux.c:	ok = ioctl (s, SIOCGIFHWADDR, (caddr_t) &ifr) >= 0;
ppp-2.4.2/pppd/sys-linux.c:    if(ioctl(skfd, SIOCGIFHWADDR, &ifr) < 0)
pump-0.8.21/dhcp.c:    if (ioctl(sock, SIOCGIFHWADDR, &req))
quagga-0.97.0/zebra/if_ioctl.c:  ret = if_ioctl (SIOCGIFHWADDR, (caddr_t) &ifreq);
radvd-0.7.2/device-linux.c:	if (ioctl(sock, SIOCGIFHWADDR, &ifr) < 0)
rarpd/rarpd.c:			if (ioctl(fd, SIOCGIFHWADDR, ifrp)) {
rarpd/rarpd.c.ss981107:			if (ioctl(fd, SIOCGIFHWADDR, ifrp)) {
rhpl-0.148/src/ethtool/ethtool.c:  err = ioctl(fd, SIOCGIFHWADDR, &ifr);
rhpl-0.148/src/ethtool/iwlib.c:  if((ioctl(skfd, SIOCGIFHWADDR, &ifr) < 0) ||
rp-pppoe-3.5/src/if.c:	if (ioctl(fd, SIOCGIFHWADDR, &ifr) < 0) {
rp-pppoe-3.5/src/plugin.c:	    if (ioctl(fd, SIOCGIFHWADDR, &ifr) < 0) {
scrollkeeper-0.3.14/libuuid/gen_uuid.c:		if (ioctl(sd, SIOCGIFHWADDR, &ifr) < 0)
tcpdump-3.8.2/libpcap-0.8.3/pcap-linux.c:	if (ioctl(fd, SIOCGIFHWADDR, &ifr) == -1) {
wvstreams-3.75.0/linuxstreams/wvinterface.cc:        if (req(SIOCGIFHWADDR, &ifr))
efibootmgr (not in FC, but I'm the upstream maintainer on it and know
it looks at just 6 bytes).


Here's what 2.2.0 (possibly earlier) through 2.4.(current) has:
  memcpy(ifr->ifr_hwaddr.sa_data,dev->dev_addr, MAX_ADDR_LEN);
  ifr->ifr_hwaddr.sa_family=dev->type;
  return 0;

Here's what 2.6 has:
  memcpy(ifr->ifr_hwaddr.sa_data, dev->dev_addr,
         min(sizeof ifr->ifr_hwaddr.sa_data,
	          (size_t) dev->addr_len));
  ifr->ifr_hwaddr.sa_family = dev->type;
  return 0;

Thus for dev->addr_len < MAX_ADDR_LEN (8), the behavior is different
(fewer bytes are copied, discarding what was most likely zeros)
and for dev->addr_len > MAX_ADDR_LEN, the behaviour is different too
(more valid bytes are copied), a good thing for apps that care and a
no-op for those that thought 6 was a useful number.

> Having said that i think we should somehow signal that info to user
> space. perhaps returning -EINVAL in the case the L2 address is 0?
> EINVAL will break a few apps and make them puke as opposed to silently
> returning something wrong.

My immediate concern was net-snmp, which, on failure, will do the
right thing if returning -EINVAL in this case.  I did not review all
the above to know if they would behave correctly on -EINVAL in that
case.

I think -EOVERFLOW would be appropriate return for dev->addr_len >
sizeof sa_data, yes?

I'd prefer though, that an "obsolete" function, be marked as such
somehow (perhaps print a net_ratelimit()ed KERN_DEBUG message when
it's called telling apps to move to rtnetlink), and that the behaviour
for everything except overflow be consistent with the prior
implementation, at least until such a time that all the apps in the
distros are converted to rtnetlink.

Thanks,
Matt

-- 
Matt Domsch
Sr. Software Engineer, Lead Engineer
Dell Linux Solutions linux.dell.com & www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com
