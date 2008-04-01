From: "Dave Young" <hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: bluetooth lockdep trace. (.25rc5-git4)
Date: Tue, 1 Apr 2008 16:58:46 +0800
Message-ID: <a8e1da0804010158u26d8b2f6pcf18face16a60714@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davej-rdkfGonbjUTCLXcRTR1eJlpr/1R2p/CL@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"Marcel Holtmann" <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
To: "David Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 1, 2008 at 4:59 PM, Dave Young <hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org
>  Bcc:
>  Subject: Re: bluetooth lockdep trace. (.25rc5-git4)
>  Reply-To:
>  In-Reply-To: <20080328.182021.46780895.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
>
>  On Fri, Mar 28, 2008 at 06:20:21PM -0700, David Miller wrote:
>  > From: Dave Jones <davej-rdkfGonbjUTCLXcRTR1eJlpr/1R2p/CL@public.gmane.org>
>  > Date: Thu, 27 Mar 2008 12:21:56 -0400
>  >
>  > > Mar 27 08:10:57 localhost kernel: Pid: 3611, comm: obex-data-serve Not tainted 2.6.25-0.121.rc5.git4.fc9 #1
>  > > Mar 27 08:10:57 localhost kernel:  [__lock_acquire+2287/3089] __lock_acquire+0x8ef/0xc11
>  > > Mar 27 08:10:57 localhost kernel:  [sched_clock+8/11] ? sched_clock+0x8/0xb
>  > > Mar 27 08:10:57 localhost kernel:  [lock_acquire+106/144] lock_acquire+0x6a/0x90
>  > > Mar 27 08:10:57 localhost kernel:  [<f8bd9321>] ? l2cap_sock_bind+0x29/0x108 [l2cap]
>  > > Mar 27 08:10:57 localhost kernel:  [lock_sock_nested+182/198] lock_sock_nested+0xb6/0xc6
>  > > Mar 27 08:10:57 localhost kernel:  [<f8bd9321>] ? l2cap_sock_bind+0x29/0x108 [l2cap]
>  > > Mar 27 08:10:57 localhost kernel:  [security_socket_post_create+22/27] ? security_socket_post_create+0x16/0x1b
>  > > Mar 27 08:10:57 localhost kernel:  [__sock_create+388/472] ? __sock_create+0x184/0x1d8
>  > > Mar 27 08:10:57 localhost kernel:  [<f8bd9321>] l2cap_sock_bind+0x29/0x108 [l2cap]
>  > > Mar 27 08:10:57 localhost kernel:  [kernel_bind+10/13] kernel_bind+0xa/0xd
>  > > Mar 27 08:10:57 localhost kernel:  [<f8dad3d7>] rfcomm_dlc_open+0xc8/0x294 [rfcomm]
>  > > Mar 27 08:10:57 localhost kernel:  [lock_sock_nested+187/198] ? lock_sock_nested+0xbb/0xc6
>  > > Mar 27 08:10:57 localhost kernel:  [<f8dae18c>] rfcomm_sock_connect+0x8b/0xc2 [rfcomm]
>  > > Mar 27 08:10:57 localhost kernel:  [sys_connect+96/125] sys_connect+0x60/0x7d
>  > > Mar 27 08:10:57 localhost kernel:  [__lock_acquire+1370/3089] ? __lock_acquire+0x55a/0xc11
>  > > Mar 27 08:10:57 localhost kernel:  [sys_socketcall+140/392] sys_socketcall+0x8c/0x188
>  > > Mar 27 08:10:57 localhost kernel:  [syscall_call+7/11] syscall_call+0x7/0xb
>  >
>  > rfcomm connect locks the socket, then does rfcomm_dlc_open which in
>  > turn can do a l2cap_sock_bind on a seperate second socket which in
>  > turn locks that second socket.
>  >
>  > Both of these sockets are AF_BLUETOOTH family, so lockdep thinks there
>  > is a locking conflict, even though what is happening here is perfectly
>  > fine since the two sockets are totally different AF_BLUETOOTH
>  > sub-types.
>  >
>  > Bluetooth will need to use sock_lock_init_class_and_name() and
>  > lock sub-classes per AF_BLUETOOTH socket sub-type.
>  >
>  > David, could you or someone else work on this?
>
>  Does this fix the problem?
>
>  ---
>  'rfcomm connect' will trigger lockdep warnings which is caused by
>  locking diffrent kinds of bluetooth sockets at the same time.
>
>  So using sub-classes per AF_BLUETOOTH sub-type for lockdep.
>
>  Thanks for the hints from dave jones.
>
>
>  Signed-off-by: Dave Young <hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>
>  ---
>  net/bluetooth/af_bluetooth.c |   40 ++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 40 insertions(+)
>
>  diff -upr linux/net/bluetooth/af_bluetooth.c linux.new/net/bluetooth/af_bluetooth.c
>  --- linux/net/bluetooth/af_bluetooth.c  2008-04-01 16:09:17.000000000 +0800
>  +++ linux.new/net/bluetooth/af_bluetooth.c      2008-04-01 16:08:52.000000000 +0800
>  @@ -53,6 +53,30 @@
>   /* Bluetooth sockets */
>   #define BT_MAX_PROTO   8
>   static struct net_proto_family *bt_proto[BT_MAX_PROTO];
>  +
>  +static struct lock_class_key bt_slock_key[BT_MAX_PROTO];
>  +static struct lock_class_key bt_lock_key[BT_MAX_PROTO];
>  +static const char *bt_key_strings[BT_MAX_PROTO] = {
>  +       "sk_lock-AF_BLUETOOTH-BTPROTO_L2CAP",
>  +       "sk_lock-AF_BLUETOOTH-BTPROTO_HCI",
>  +       "sk_lock-AF_BLUETOOTH-BTPROTO_SCO",
>  +       "sk_lock-AF_BLUETOOTH-BTPROTO_RFCOMM",
>  +       "sk_lock-AF_BLUETOOTH-BTPROTO_BNEP",
>  +       "sk_lock-AF_BLUETOOTH-BTPROTO_CMTP",
>  +       "sk_lock-AF_BLUETOOTH-BTPROTO_HIDP",
>  +       "sk_lock-AF_BLUETOOTH-BTPROTO_AVDTP",
>  +};
>  +
>  +static const char *bt_slock_key_strings[BT_MAX_PROTO] = {
>  +       "slock-AF_BLUETOOTH-BTPROTO_L2CAP",
>  +       "slock-AF_BLUETOOTH-BTPROTO_HCI",
>  +       "slock-AF_BLUETOOTH-BTPROTO_SCO",
>  +       "slock-AF_BLUETOOTH-BTPROTO_RFCOMM",
>  +       "slock-AF_BLUETOOTH-BTPROTO_BNEP",
>  +       "slock-AF_BLUETOOTH-BTPROTO_CMTP",
>  +       "slock-AF_BLUETOOTH-BTPROTO_HIDP",
>  +       "slock-AF_BLUETOOTH-BTPROTO_AVDTP",
>  +};
>   static DEFINE_RWLOCK(bt_proto_lock);
>
>   int bt_sock_register(int proto, struct net_proto_family *ops)
>  @@ -95,6 +119,21 @@ int bt_sock_unregister(int proto)
>   }
>   EXPORT_SYMBOL(bt_sock_unregister);
>
>  +static void bt_reclassify_sock_lock(struct socket *sock, int proto)
>  +{
>  +       struct sock *sk = sock->sk;
>  +
>  +       if (!sk)
>  +               return;
>  +       BUG_ON(sock_owned_by_user(sk));
>  +
>  +       sock_lock_init_class_and_name(sk,
>  +                       bt_slock_key_strings[proto],
>  +                       &bt_slock_key[proto],
>  +                       bt_key_strings[proto],
>  +                       &bt_lock_key[proto]);
>  +}
>  +
>   static int bt_sock_create(struct net *net, struct socket *sock, int proto)
>   {
>         int err;
>  @@ -117,6 +156,7 @@ static int bt_sock_create(struct net *ne
>
>         if (bt_proto[proto] && try_module_get(bt_proto[proto]->owner)) {
>                 err = bt_proto[proto]->create(net, sock, proto);
>  +               bt_reclassify_sock_lock(sock, proto);
>                 module_put(bt_proto[proto]->owner);
>         }
>
>

Sorry, the subject was cut by my mistake, please don't mind.

Regards
dave
