From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: fold network name hash (v2)
Date: Wed, 28 Oct 2009 07:07:10 +0100
Message-ID: <4AE7DF8E.3020607@gmail.com>
References: <9986527.24561256620662709.JavaMail.root@tahiti.vyatta.com>	<19864844.24581256620784317.JavaMail.root@tahiti.vyatta.com>	<20091026.222428.80364204.davem@davemloft.net>	<20091027102251.244ee681@nehalam> <20091027150436.56e673cd@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	torvalds@linux-foundation.org, opurdila@ixiacom.com,
	viro@zeniv.linux.org.uk
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757411AbZJ1GHS@vger.kernel.org>
In-Reply-To: <20091027150436.56e673cd@nehalam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger a =E9crit :
> The full_name_hash does not produce a value that is evenly distribute=
d
> over the lower 8 bits. This causes name hash to be unbalanced with la=
rge
> number of names. There is a standard function to fold in upper bits
> so use that.
>=20
> This is independent of possible improvements to full_name_hash()
> in future.

>  static inline struct hlist_head *dev_name_hash(struct net *net, cons=
t char *name)
>  {
>  	unsigned hash =3D full_name_hash(name, strnlen(name, IFNAMSIZ));
> -	return &net->dev_name_head[hash & ((1 << NETDEV_HASHBITS) - 1)];
> +	return &net->dev_name_head[hash_long(hash, NETDEV_HASHBITS)];
>  }
> =20
>  static inline struct hlist_head *dev_index_hash(struct net *net, int=
 ifindex)

full_name_hash() returns an "unsigned int", which is guaranteed to be 3=
2 bits

You should therefore use hash_32(hash, NETDEV_HASHBITS),
not hash_long() that maps to hash_64() on 64 bit arches, which is
slower and certainly not any better with a 32bits input.



/* Compute the hash for a name string. */
static inline unsigned int
full_name_hash(const unsigned char *name, unsigned int len)
{
        unsigned long hash =3D init_name_hash();
        while (len--)
                hash =3D partial_name_hash(*name++, hash);
        return end_name_hash(hash);
}

static inline u32 hash_32(u32 val, unsigned int bits)
{
        /* On some cpus multiply is faster, on others gcc will do shift=
s */
        u32 hash =3D val * GOLDEN_RATIO_PRIME_32;

        /* High bits are more random, so use them. */
        return hash >> (32 - bits);
}


static inline u64 hash_64(u64 val, unsigned int bits)
{
        u64 hash =3D val;

        /*  Sigh, gcc can't optimise this alone like it does for 32 bit=
s. */
        u64 n =3D hash;
        n <<=3D 18;
        hash -=3D n;
        n <<=3D 33;
        hash -=3D n;
        n <<=3D 3;
        hash +=3D n;
        n <<=3D 3;
        hash -=3D n;
        n <<=3D 4;
        hash +=3D n;
        n <<=3D 2;
        hash +=3D n;

        /* High bits are more random, so use them. */
        return hash >> (64 - bits);
}
