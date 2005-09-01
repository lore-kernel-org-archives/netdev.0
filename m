From: Ben Greear <greearb@candelatech.com>
Subject: Re: Netdevice reference leak in af_ax25.c ??
Date: Thu, 01 Sep 2005 12:02:01 -0700
Message-ID: <43175029.2020204@candelatech.com>
References: <43174B67.9030109@candelatech.com> <43174ED3.6040106@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-hams@vger.kernel.org, ralf@linux-mips.org,
	netdev@vger.kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <43174ED3.6040106@trash.net>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Ben Greear wrote:
> 
>>I believe the SO_BINDTODEVICE case in net/ax25/af_x25.c  (line 613 or so)
>>leaks a reference to a net device.  It does a dev_get_by_name,
>>which holds a reference, but since it never assigns the pointer
>>anywhere, I do not see how it can ever free it later.
>>
>>Please clue me in as to where it's released if it actually is.
> 
> 
> I can't find the code you're talking about, there's no dev_get* in my
> version of af_x25.c. Please paste the code you're talking about in
> your bugreports, thanks.

Please ignore the NRDK thing..I am adding reference counting debugging
to the netdevice code.  This is from the 2.6.13 kernel:

In this method:

/*
  *	Handling for system calls applied via the various interfaces to an
  *	AX25 socket object
  */

static int ax25_setsockopt(struct socket *sock, int level, int optname,
	char __user *optval, int optlen)
{

.....

	case SO_BINDTODEVICE:
		if (optlen > IFNAMSIZ)
			optlen=IFNAMSIZ;
		if (copy_from_user(devname, optval, optlen)) {
		res = -EFAULT;
			break;
		}

		dev = dev_get_by_name(devname, NDRK_GENERIC);
		if (dev == NULL) {
			res = -ENODEV;
			break;
		}

		if (sk->sk_type == SOCK_SEQPACKET &&
		   (sock->state != SS_UNCONNECTED ||
		    sk->sk_state == TCP_LISTEN)) {
			res = -EADDRNOTAVAIL;
			dev_put(dev, NDRK_GENERIC);
			break;
		}

		ax25->ax25_dev = ax25_dev_ax25dev(dev);
		ax25_fillin_cb(ax25, ax25->ax25_dev);
                 dev_put(dev, NDRK_GENERIC); /* TODO:  Verify we should put it here. */
		break;

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

