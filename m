From: Vincent Li <vincent.mc.li@gmail.com>
Subject: Re: add ip to interface as primary ip address, not secondary ip when
 there is alreadly primary ip?
Date: Thu, 19 Sep 2013 09:54:53 -0700
Message-ID: <CAK3+h2yWjswp6qrToMPbrQyuyCKkh5Yuuo6TeX8VhGQCGpCecw@mail.gmail.com>
References: <CAK3+h2zPYYLaVs-WhHFaDhOsnLBB7m8vDvkTj5a16FUJ02i4KA@mail.gmail.com>
	<l1as5j$7cs$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:54957 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751660Ab3ISQyx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Sep 2013 12:54:53 -0400
Received: by mail-ob0-f172.google.com with SMTP id gq1so10353304obb.3
        for <netdev@vger.kernel.org>; Thu, 19 Sep 2013 09:54:53 -0700 (PDT)
In-Reply-To: <l1as5j$7cs$1@ger.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

thanks for the pointer

'ip addr' indeed has flag IFA_F_SECONDARY for this, but it is not
available for 'ip addr add', so I made a simple patch for iproute2
ip/ipaddress.c as below:

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 1c3e4da..b5aa96a 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -1307,6 +1307,11 @@ static int ipaddr_modify(int cmd, int flags,
int argc, char **argv)
                                invarg("invalid scope value.", *argv);
                        req.ifa.ifa_scope = scope;
                        scoped = 1;
+                } else if (strcmp(*argv, "secondary") == 0 ||
+                           strcmp(*argv, "temporary") == 0) {
+                        req.ifa.ifa_flags |= IFA_F_SECONDARY;
+                } else if (strcmp(*argv, "primary") == 0) {
+                        req.ifa.ifa_flags &= ~IFA_F_SECONDARY;
                } else if (strcmp(*argv, "dev") == 0) {
                        NEXT_ARG();
                        d = *argv;

I also found that I need to patch up the kernel and here is the kernel
patch, it might look silly, but it works as I tested

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index a1b5bcb..2a1d61b 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -440,14 +440,18 @@ static int __inet_insert_ifa(struct in_ifaddr
*ifa, struct nlmsghdr *nlh,
                return 0;
        }

-       ifa->ifa_flags &= ~IFA_F_SECONDARY;
        last_primary = &in_dev->ifa_list;

        for (ifap = &in_dev->ifa_list; (ifa1 = *ifap) != NULL;
             ifap = &ifa1->ifa_next) {
                if (!(ifa1->ifa_flags & IFA_F_SECONDARY) &&
-                   ifa->ifa_scope <= ifa1->ifa_scope)
-                       last_primary = &ifa1->ifa_next;
+                   ifa->ifa_scope <= ifa1->ifa_scope) {
+                        if (ifa->ifa_flags & IFA_F_SECONDARY) {
+                                last_primary = &ifa1->ifa_next;
+                        } else {
+                                ifa1->ifa_flags |= IFA_F_SECONDARY;
+                        }
+                }
                if (ifa1->ifa_mask == ifa->ifa_mask &&
                    inet_ifa_match(ifa1->ifa_address, ifa)) {
                        if (ifa1->ifa_local == ifa->ifa_local) {
@@ -458,7 +462,11 @@ static int __inet_insert_ifa(struct in_ifaddr
*ifa, struct nlmsghdr *nlh,
                                inet_free_ifa(ifa);
                                return -EINVAL;
                        }
-                       ifa->ifa_flags |= IFA_F_SECONDARY;
+                        if (ifa->ifa_flags & IFA_F_SECONDARY) {
+                                ifa->ifa_flags |= IFA_F_SECONDARY;
+                        } else {
+                                ifa->ifa_flags &= ~IFA_F_SECONDARY;
+                        }
                }
        }

my test steps:

1
 ./ip/ip addr add 192.168.1.1/24 scope global secondary dev eth0
./ip/ip adrr show eth0 >> /tmp/ipaddr.txt

2
./ip/ip addr add 192.168.1.2/24 scope global primary dev eth0
./ip/ip addr show eth0 >> /tmp/ipaddr.txt

3
./ip/ip addr add 192.168.1.3/24 scope global primary dev eth0
./ip/ip addr show eth0 >> /tmp/ipaddr.txt

4
./ip/ip addr add 192.168.1.4/24 scope global secondary dev eth0
./ip/ip addr show eth0 >> /tmp/ipaddr.txt

5
./ip/ip addr add 192.168.1.5/24 scope global  dev eth0
./ip/ip addr show eth0 >> /tmp/ipaddr.txt

6
./ip/ip addr del 192.168.1.5/24  dev eth0
./ip/ip addr show eth0 >> /tmp/ipaddr.txt

test result for each step

result 1

2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
state UP group default qlen 1000
    link/ether 52:54:00:e3:8f:33 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.1/24 scope global secondary eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::5054:ff:fee3:8f33/64 scope link
       valid_lft forever preferred_lft forever

result 2

2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
state UP group default qlen 1000
    link/ether 52:54:00:e3:8f:33 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.2/24 scope global eth0
       valid_lft forever preferred_lft forever
    inet 192.168.1.1/24 scope global secondary eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::5054:ff:fee3:8f33/64 scope link
       valid_lft forever preferred_lft forever

result 3

2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
state UP group default qlen 1000
    link/ether 52:54:00:e3:8f:33 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.3/24 scope global eth0
       valid_lft forever preferred_lft forever
    inet 192.168.1.2/24 scope global secondary eth0
       valid_lft forever preferred_lft forever
    inet 192.168.1.1/24 scope global secondary eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::5054:ff:fee3:8f33/64 scope link
       valid_lft forever preferred_lft forever

result 4

2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
state UP group default qlen 1000
    link/ether 52:54:00:e3:8f:33 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.3/24 scope global eth0
       valid_lft forever preferred_lft forever
    inet 192.168.1.2/24 scope global secondary eth0
       valid_lft forever preferred_lft forever
    inet 192.168.1.1/24 scope global secondary eth0
       valid_lft forever preferred_lft forever
    inet 192.168.1.4/24 scope global secondary eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::5054:ff:fee3:8f33/64 scope link
       valid_lft forever preferred_lft forever

result 5

2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
state UP group default qlen 1000
    link/ether 52:54:00:e3:8f:33 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.5/24 scope global eth0
       valid_lft forever preferred_lft forever
    inet 192.168.1.3/24 scope global secondary eth0
       valid_lft forever preferred_lft forever
    inet 192.168.1.2/24 scope global secondary eth0
       valid_lft forever preferred_lft forever
    inet 192.168.1.1/24 scope global secondary eth0
       valid_lft forever preferred_lft forever
    inet 192.168.1.4/24 scope global secondary eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::5054:ff:fee3:8f33/64 scope link
       valid_lft forever preferred_lft forever

result 6

2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
state UP group default qlen 1000
    link/ether 52:54:00:e3:8f:33 brd ff:ff:ff:ff:ff:ff
    inet6 fe80::5054:ff:fee3:8f33/64 scope link
       valid_lft forever preferred_lft forever

it does seems to achieve what I wanted, any comment on this?



On Tue, Sep 17, 2013 at 5:29 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Tue, 17 Sep 2013 at 22:31 GMT, Vincent Li <vincent.mc.li@gmail.com> wrote:
>>
>> ideally though, we would like to have the capability in
>> kernel/userspace  to specify a flag or something to add any ip as
>> primary even if there is already existing primary ip address (could
>> downgrade the existing primary to secondary ip). does this make sense
>> ?
>
> 'ip addr' already has flags for this.
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
