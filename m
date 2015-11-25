From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [Resend PATCH] RDS: fix race condition when sending a message
 on unbound socket
Date: Wed, 25 Nov 2015 12:21:45 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CBDC0B0@AcuExch.aculab.com>
References: <1448403201-1683-1-git-send-email-santosh.shilimkar@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"sasha.levin@oracle.com" <sasha.levin@oracle.com>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	Quentin Casasnovas <quentin.casasnovas@oracle.com>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>
To: 'Santosh Shilimkar' <santosh.shilimkar@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448403201-1683-1-git-send-email-santosh.shilimkar@oracle.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Santosh Shilimkar
> Sent: 24 November 2015 22:13
...
> Sasha's found a NULL pointer dereference in the RDS connection code when
> sending a message to an apparently unbound socket.  The problem is caused
> by the code checking if the socket is bound in rds_sendmsg(), which checks
> the rs_bound_addr field without taking a lock on the socket.  This opens a
> race where rs_bound_addr is temporarily set but where the transport is not
> in rds_bind(), leading to a NULL pointer dereference when trying to
> dereference 'trans' in __rds_conn_create().
> 
> Vegard wrote a reproducer for this issue, so kindly ask him to share if
> you're interested.
...
> diff --git a/net/rds/send.c b/net/rds/send.c
> index 827155c..c9cdb35 100644
> --- a/net/rds/send.c
> +++ b/net/rds/send.c
> @@ -1013,11 +1013,13 @@ int rds_sendmsg(struct socket *sock, struct msghdr *msg, size_t payload_len)
>  		release_sock(sk);

This is falling though into an unconditional lock_sock().
No need to unlock and relock immediately.

>  	}
> 
> -	/* racing with another thread binding seems ok here */
> +	lock_sock(sk);
>  	if (daddr == 0 || rs->rs_bound_addr == 0) {
> +		release_sock(sk);
>  		ret = -ENOTCONN; /* XXX not a great errno */
>  		goto out;
>  	}
> +	release_sock(sk);
> 

On the face of it the above looks somewhat dubious.
Locks usually tie together two action (eg a test and use of a value),
In this case you only have a test inside the lock.
That either means that the state can change after you release the lock
(ie rs->rs_bound_addr = 0 is executed somewhere), or you don't
really need the lock.

	David
