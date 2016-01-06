From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] rfcomm: fix information leak in rfcomm_sock_bind
Date: Tue, 5 Jan 2016 22:48:18 -0800
Message-ID: <62ADF1E9-4974-4F54-8D86-CE0E38CC4619@holtmann.org>
References: <1452054993-76111-1-git-send-email-wuninsu@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 9.2 \(3112\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "Gustavo F. Padovan" <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Peter Hurley <peter@hurleysoftware.com>,
	JAGANATH KANAKKASSERY <jaganath.k@samsung.com>,
	ying.xue@windriver.com,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	BlueZ development <linux-bluetooth@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, taesoo@gatech.edu,
	yeongjin.jang@gatech.edu, insu@gatech.edu, changwoo@gatech.edu
To: Insu Yun <wuninsu@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452054993-76111-1-git-send-email-wuninsu@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Insu,

> if addr_len < sizeof(sa), sa.rc_bdaddr(4bytes) can be leaked 
> by using rfcomm_sock_getname()
> 
> Signed-off-by: Insu Yun <wuninsu@gmail.com>
> ---
> net/bluetooth/rfcomm/sock.c | 9 +++++----
> 1 file changed, 5 insertions(+), 4 deletions(-)
> 
> diff --git a/net/bluetooth/rfcomm/sock.c b/net/bluetooth/rfcomm/sock.c
> index 7511df7..d61dfdc 100644
> --- a/net/bluetooth/rfcomm/sock.c
> +++ b/net/bluetooth/rfcomm/sock.c
> @@ -336,14 +336,15 @@ static int rfcomm_sock_bind(struct socket *sock, struct sockaddr *addr, int addr
> {
> 	struct sockaddr_rc sa;
> 	struct sock *sk = sock->sk;
> -	int len, err = 0;
> +	int err = 0;
> 
> 	if (!addr || addr->sa_family != AF_BLUETOOTH)
> 		return -EINVAL;
> 
> -	memset(&sa, 0, sizeof(sa));
> -	len = min_t(unsigned int, sizeof(sa), addr_len);
> -	memcpy(&sa, addr, len);

what are we leaking here?

If you make addr_len (controlled by userspace) smaller than struct sockaddr_rc, the kernel will only copy addr_len of sockaddr_rc to userspace. What is the kernel leaking again? We are happy to hand out the full sockaddr_rc in the first place.

> +	if (addr_len != sizeof(sa))
> +		return -EINVAL;
> +
> +	memcpy(&sa, addr, addr_len);
> 
> 	BT_DBG("sk %p %pMR", sk, &sa.rc_bdaddr);

While I give you the fact that we should require at minimum to provide bdaddr_t and channel just as a good safe guard, but even if you don't, then it just means you try to bind to a truncated address, which will fail when calling connect().

So the sockaddr_rc sa will be memset to zero. Which means if you provide less than sockaddr_rc you get a truncated rc_bdaddr and rc_channel set to zero. So what is getname() leaking now. It will leak zeros. It will not leak random kernel memory.

Please help me to understand where this is an information leak. Since leaking memory that is explicitly set to zero is not an information leak.

And just FYI you can bind a RFCOMM socket to a truncated address and channel 0 in a valid way with the full size of sockaddr_rc. That is still valid. We do not discriminate any addresses. If some company manages to get the IEEE to assign that address to them, than that is a valid address.

Regards

Marcel
