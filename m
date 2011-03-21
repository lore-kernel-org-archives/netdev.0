From: "Ferraton, Jean RegisX" <jean.regisx.ferraton@intel.com>
Subject: RE: [PATCH] Fix "possible circular locking dependency" in rfcomm
Date: Mon, 21 Mar 2011 08:43:59 +0000
Message-ID: <6E42A1B4DD2F7B4D80A1F26BB498BF9F8CA7FB959D@irsmsx501.ger.corp.intel.com>
References: <6E42A1B4DD2F7B4D80A1F26BB498BF9F8C9F86D162@irsmsx501.ger.corp.intel.com>
 <6E42A1B4DD2F7B4D80A1F26BB498BF9F8C9F8C1539@irsmsx501.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "marcel@holtmann.org" <marcel@holtmann.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"xiaosuo@gmail.com" <xiaosuo@gmail.com>,
	"linux-bluetooth@vger.kernel.org" <linux-bluetooth@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Gustavo F. Padovan" <padovan@profusion.mobi>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6E42A1B4DD2F7B4D80A1F26BB498BF9F8C9F8C1539@irsmsx501.ger.corp.intel.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Any comment?

> -----Original Message-----
> From: linux-bluetooth-owner@vger.kernel.org [mailto:linux-bluetooth-
> owner@vger.kernel.org] On Behalf Of Ferraton, Jean RegisX
> Sent: Monday, March 14, 2011 3:56 PM
> To: Gustavo F. Padovan
> Cc: marcel@holtmann.org; davem@davemloft.net; eric.dumazet@gmail.com;
> xiaosuo@gmail.com; linux-bluetooth@vger.kernel.org; linux-
> kernel@vger.kernel.org; netdev@vger.kernel.org
> Subject: [PATCH] Fix "possible circular locking dependency" in rfcomm
> 
> No response from original post, submit again, more details below:
> 
> Changes in sock.c in function __rfcomm_sock_close, to release sock before
> calling rfcomm_dlc_close to avoid possible deadlock when calling
> rfcomm_lock (in rfcomm_dlc_close).
> 
> Signed-off-by: Jean Regis Ferraton <jrferraton@gmail.com>
> 
> ---
>  net/bluetooth/rfcomm/sock.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/net/bluetooth/rfcomm/sock.c b/net/bluetooth/rfcomm/sock.c
> index 66cc1f0..3b5ec09 100644
> --- a/net/bluetooth/rfcomm/sock.c
> +++ b/net/bluetooth/rfcomm/sock.c
> @@ -234,7 +234,10 @@ static void __rfcomm_sock_close(struct sock *sk)
>  	case BT_CONNECT2:
>  	case BT_CONFIG:
>  	case BT_CONNECTED:
> +		/* release_sock to avoid deadlock when calling rfcomm_lock()
> */
> +		release_sock(sk);
>  		rfcomm_dlc_close(d, 0);
> +		lock_sock(sk);
> 
>  	default:
>  		sock_set_flag(sk, SOCK_ZAPPED);
> --
> 1.6.2.5
> 
> 
> 
> This patch solves a problem of "possible circular locking dependency"
> related to rfcomm. Problem seen on kernel 2.6.37. Maybe it's not a bug,
> just a warning, see the trace below.
> 
> This problem occurs in 2 cases:
> 1- When initiating a connection from the remote device
> 2- When browsing my BT device from my PC
> 
> My analysis is the following:
> 1- We call the function rfcomm_sock_shutdown() which locks a socket, an
> after calls __rfcomm_sock_close()
>      	lock_sock(sk);
>     	if (!sk->sk_shutdown) {
>     		sk->sk_shutdown = SHUTDOWN_MASK;
>     		__rfcomm_sock_close(sk);
> 2- In the function __rfcomm_sock_close(), we call rfcomm_dlc_close()
> 	case BT_CONNECTED:
>     		rfcomm_dlc_close(d, 0);
> 3- In the function rfcomm_dlc_close(), we call rfcomm_lock() which locks a
> mutex on rfcomm, and this second lock causes the problem.
> 	rfcomm_lock();
> 	r = __rfcomm_dlc_close(d, err);
> 
> My message trace is the following (for remote connect):
> [  113.995511] =======================================================
> [  114.001897] [ INFO: possible circular locking dependency detected ]
> [  114.008157] 2.6.37.3jrf_fix #1
> [  114.011196] -------------------------------------------------------
> [  114.017457] bluetoothd/511 is trying to acquire lock:
> [  114.022499]  (rfcomm_mutex){+.+.+.}, at: [<c14f281a>]
> rfcomm_dlc_close+0x15/0x30
> [  114.029887]
> [  114.029892] but task is already holding lock:
> [  114.035713]  (sk_lock-AF_BLUETOOTH){+.+.+.}, at: [<c14f4cfe>]
> rfcomm_sock_shutdown+0x17/0x5d
> [  114.044147]
> [  114.044152] which lock already depends on the new lock.
> [  114.044158]
> [  114.052319]
> [  114.052324] the existing dependency chain (in reverse order) is:
> [  114.059796]
> [  114.059801] -> #1 (sk_lock-AF_BLUETOOTH){+.+.+.}:
> [  114.065967]        [<c105d660>] lock_acquire+0xf9/0x135
> [  114.071184]        [<c1445cf3>] lock_sock_nested+0x55/0x65
> [  114.076662]        [<c14ed17d>] l2cap_sock_sendmsg+0x3f/0x606
> [  114.082400]        [<c1443775>] sock_sendmsg+0xc9/0xe0
> [  114.087530]        [<c14437b4>] kernel_sendmsg+0x28/0x37
> [  114.092833]        [<c14f2278>] rfcomm_send_frame+0x2f/0x37
> [  114.098398]        [<c14f232c>] rfcomm_send_ua+0x57/0x59
> [  114.103701]        [<c14f3884>] rfcomm_run+0x431/0xb06
> [  114.108830]        [<c104bc8f>] kthread+0x5f/0x64
> [  114.113525]        [<c1002b7a>] kernel_thread_helper+0x6/0x1a
> [  114.119265]
> [  114.119270] -> #0 (rfcomm_mutex){+.+.+.}:
> [  114.124739]        [<c105cff1>] __lock_acquire+0xe03/0x1379
> [  114.130304]        [<c105d660>] lock_acquire+0xf9/0x135
> [  114.135522]        [<c1522bf3>] mutex_lock_nested+0x45/0x286
> [  114.141171]        [<c14f281a>] rfcomm_dlc_close+0x15/0x30
> [  114.146650]        [<c14f4cdb>] __rfcomm_sock_close+0x5e/0x6a
> [  114.152388]        [<c14f4d12>] rfcomm_sock_shutdown+0x2b/0x5d
> [  114.158212]        [<c14f4d5d>] rfcomm_sock_release+0x19/0x60
> [  114.163951]        [<c14445da>] sock_release+0x14/0x5b
> [  114.169080]        [<c144463d>] sock_close+0x1c/0x20
> [  114.174037]        [<c10bdd19>] fput+0xfa/0x19e
> [  114.178557]        [<c10bb3c5>] filp_close+0x51/0x5b
> [  114.183512]        [<c10bb488>] sys_close+0xb9/0xee
> [  114.188381]        [<c1002650>] sysenter_do_call+0x12/0x36
> [  114.193858]
> [  114.193863] other info that might help us debug this:
> [  114.193870]
> [  114.201860] 1 lock held by bluetoothd/511:
> [  114.205945]  #0:  (sk_lock-AF_BLUETOOTH){+.+.+.}, at: [<c14f4cfe>]
> rfcomm_sock_shutdown+0x17/0x5d
> [  114.214811]
> [  114.214816] stack backtrace:
> [  114.219167] Pid: 511, comm: bluetoothd Tainted: G        WC
> 2.6.37.3jrf_fix #1
> [  114.226463] Call Trace:
> [  114.228913]  [<c152108a>] ? printk+0xf/0x11
> [  114.233086]  [<c105bc3b>] print_circular_bug+0x90/0x9c
> [  114.238211]  [<c105cff1>] __lock_acquire+0xe03/0x1379
> [  114.243260]  [<c14f281a>] ? rfcomm_dlc_close+0x15/0x30
> [  114.248382]  [<c105d660>] lock_acquire+0xf9/0x135
> [  114.253079]  [<c14f281a>] ? rfcomm_dlc_close+0x15/0x30
> [  114.258208]  [<c1522bf3>] mutex_lock_nested+0x45/0x286
> [  114.263338]  [<c14f281a>] ? rfcomm_dlc_close+0x15/0x30
> [  114.268469]  [<c105b68d>] ? trace_hardirqs_on_caller+0x100/0x121
> [  114.274467]  [<c1445cf8>] ? lock_sock_nested+0x5a/0x65
> [  114.279597]  [<c105b6b9>] ? trace_hardirqs_on+0xb/0xd
> [  114.284639]  [<c14f281a>] rfcomm_dlc_close+0x15/0x30
> [  114.289594]  [<c14f4cdb>] __rfcomm_sock_close+0x5e/0x6a
> [  114.294811]  [<c14f4d12>] rfcomm_sock_shutdown+0x2b/0x5d
> [  114.300115]  [<c14f4d5d>] rfcomm_sock_release+0x19/0x60
> [  114.305331]  [<c14445da>] sock_release+0x14/0x5b
> [  114.309937]  [<c144463d>] sock_close+0x1c/0x20
> [  114.314373]  [<c10bdd19>] fput+0xfa/0x19e
> [  114.318371]  [<c10bb3c5>] filp_close+0x51/0x5b
> [  114.322804]  [<c10bb488>] sys_close+0xb9/0xee
> [  114.327151]  [<c1002650>] sysenter_do_call+0x12/0x36
> ---------------------------------------------------------------------
> Intel Corporation SAS (French simplified joint stock company)
> Registered headquarters: "Les Montalets"- 2, rue de Paris,
> 92196 Meudon Cedex, France
> Registration Number:  302 456 199 R.C.S. NANTERRE
> Capital: 4,572,000 Euros
> 
> This e-mail and any attachments may contain confidential material for
> the sole use of the intended recipient(s). Any review or distribution
> by others is strictly prohibited. If you are not the intended
> recipient, please contact the sender and delete all copies.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-bluetooth"
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
---------------------------------------------------------------------
Intel Corporation SAS (French simplified joint stock company)
Registered headquarters: "Les Montalets"- 2, rue de Paris, 
92196 Meudon Cedex, France
Registration Number:  302 456 199 R.C.S. NANTERRE
Capital: 4,572,000 Euros

This e-mail and any attachments may contain confidential material for
the sole use of the intended recipient(s). Any review or distribution
by others is strictly prohibited. If you are not the intended
recipient, please contact the sender and delete all copies.
