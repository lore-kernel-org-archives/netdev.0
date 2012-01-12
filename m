From: Francesco Ruggeri <fruggeri@aristanetworks.com>
Subject: Race condition in ipv6 code
Date: Wed, 11 Jan 2012 18:13:55 -0800
Message-ID: <CA+HUmGhJ-YvFMRnKzb8RqH6COZ=erp1SajVcb1rq1vi2k9OBGw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:44260 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751974Ab2ALCN4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2012 21:13:56 -0500
Received: by iabz25 with SMTP id z25so1956784iab.19
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2012 18:13:56 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have hit a race condition in ipv6 code when setting
/proc/sys/net/ipv6/conf/*/forwarding. This happens when the syscall
has to be restarted.

I wonder if anyone else has run into the same issue.

The current sequence in addrconf_sysctl_forward() and
addrconf_fixup_forwarding()=A0 is as follows:
- change the parameter in idev->cnf.forwarding (using proc_dointvec())
- try to get the rtnl lock
- if cannot get the lock then restore the original value in
idev->cnf.forwarding and restart the syscall.

While this is going on, the ipv6 code may access idev->cnf.forwarding
and get an incorrect value.
In our case we were in addrconf_ifdown (holding the rtnl lock)=A0 and
calling __ipv6_ifa_notify(RTM_DELADDR, ifa) on the idev->addr_list
entries.
__ipv6_ifa_notify() only invokes addrconf_leave_anycast() if
idev->cnf.forwarding is set. Because a process trying to set
forwarding to 0 was stuck in the restart_syscall sequence above
flipping the flag on and off, we erroneously read the flag as 0, with
the result that addrconf_leave_anycast() was not invoked, some
idev->ac_list entries were never released, idev was never freed and
kept a reference to its net_device, and the net_device was never freed
and caused the "unregister_netdevice: waiting for xxx to become free"
message forever. In our case this was a vlan interfaces that was being
deleted, so we ended up getting stuck in vlan_ioctl_handler() holding
vlan_ioctl_mutex with further bad consequences.
The following diffs (for 2.6.38, but the same logic seems to be used
in 3.2) address the issue by modifying idev->cnf.forwarding only after
the rtnl lock is acquired. There is a similar situation for
disable_ipv6.
Any comments are appreciated.

=46rancesco Ruggeri


--- a/net/ipv6/addrconf.c    2011-03-14 18:20:32.000000000 -0700
+++ b/net/ipv6/addrconf.c    2012-01-10 12:56:01.458880292 -0800
@@ -507,29 +507,31 @@ static void addrconf_forward_change(stru
     rcu_read_unlock();
 }

-static int addrconf_fixup_forwarding(struct ctl_table *table, int *p, =
int old)
+static int addrconf_fixup_forwarding(struct ctl_table *table, int *p, =
int newf)
 {
     struct net *net;
+    int old;

     net =3D (struct net *)table->extra2;
-    if (p =3D=3D &net->ipv6.devconf_dflt->forwarding)
+    if (p =3D=3D &net->ipv6.devconf_dflt->forwarding) {
+        *p =3D newf;
         return 0;
+    }

-    if (!rtnl_trylock()) {
-        /* Restore the original values before restarting */
-        *p =3D old;
+    if (!rtnl_trylock())
         return restart_syscall();
-    }
+
+    old =3D *p;
+    *p =3D newf;

     if (p =3D=3D &net->ipv6.devconf_all->forwarding) {
-        __s32 newf =3D net->ipv6.devconf_all->forwarding;
         net->ipv6.devconf_dflt->forwarding =3D newf;
         addrconf_forward_change(net, newf);
-    } else if ((!*p) ^ (!old))
+    } else if ((!newf) ^ (!old))
         dev_forward_change((struct inet6_dev *)table->extra1);
     rtnl_unlock();

-    if (*p)
+    if (newf)
         rt6_purge_dflt_routers(net);
     return 1;
 }
@@ -4165,9 +4167,17 @@ int addrconf_sysctl_forward(ctl_table *c
     int *valp =3D ctl->data;
     int val =3D *valp;
     loff_t pos =3D *ppos;
+    ctl_table lctl;
     int ret;

-    ret =3D proc_dointvec(ctl, write, buffer, lenp, ppos);
+    /*
+     * ctl->data points to idev->cnf.forwarding, we should
+     * not modify it until we get the rtnl lock.
+     */
+    lctl =3D *ctl;
+    lctl.data =3D &val;
+
+    ret =3D proc_dointvec(&lctl, write, buffer, lenp, ppos);

     if (write)
         ret =3D addrconf_fixup_forwarding(ctl, valp, val);
@@ -4205,26 +4215,28 @@ static void addrconf_disable_change(stru
     rcu_read_unlock();
 }

-static int addrconf_disable_ipv6(struct ctl_table *table, int *p, int =
old)
+static int addrconf_disable_ipv6(struct ctl_table *table, int *p, int =
newf)
 {
     struct net *net;
+    int old;

     net =3D (struct net *)table->extra2;

-    if (p =3D=3D &net->ipv6.devconf_dflt->disable_ipv6)
+    if (p =3D=3D &net->ipv6.devconf_dflt->disable_ipv6) {
+        *p =3D newf;
         return 0;
+    }

-    if (!rtnl_trylock()) {
-        /* Restore the original values before restarting */
-        *p =3D old;
+    if (!rtnl_trylock())
         return restart_syscall();
-    }
+
+    old =3D *p;
+    *p =3D newf;

     if (p =3D=3D &net->ipv6.devconf_all->disable_ipv6) {
-        __s32 newf =3D net->ipv6.devconf_all->disable_ipv6;
         net->ipv6.devconf_dflt->disable_ipv6 =3D newf;
         addrconf_disable_change(net, newf);
-    } else if ((!*p) ^ (!old))
+    } else if ((!newf) ^ (!old))
         dev_disable_change((struct inet6_dev *)table->extra1);

     rtnl_unlock();
@@ -4238,9 +4250,17 @@ int addrconf_sysctl_disable(ctl_table *c
     int *valp =3D ctl->data;
     int val =3D *valp;
     loff_t pos =3D *ppos;
+    ctl_table lctl;
     int ret;

-    ret =3D proc_dointvec(ctl, write, buffer, lenp, ppos);
+    /*
+     * ctl->data points to idev->cnf.disable_ipv6, we should
+     * not modify it until we get the rtnl lock.
+     */
+    lctl =3D *ctl;
+    lctl.data =3D &val;
+
+    ret =3D proc_dointvec(&lctl, write, buffer, lenp, ppos);

     if (write)
         ret =3D addrconf_disable_ipv6(ctl, valp, val);
