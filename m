From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: Re: [PATCH 3/4] net: mv643xx_eth: use kzalloc
Date: Wed, 09 Sep 2015 20:34:27 +0200
Message-ID: <87r3m74f2k.fsf@rasmusvillemoes.dk>
References: <1441787886-7214-1-git-send-email-linux@rasmusvillemoes.dk>
	<1441787886-7214-4-git-send-email-linux@rasmusvillemoes.dk>
	<1441814431.17219.46.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1441814431.17219.46.camel@perches.com> (Joe Perches's message of
	"Wed, 09 Sep 2015 09:00:31 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 09 2015, Joe Perches <joe@perches.com> wrote:

> On Wed, 2015-09-09 at 10:38 +0200, Rasmus Villemoes wrote:
>> The double memset is a little ugly; using kzalloc avoids it altogether.
> []
>> diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
> []
>> @@ -1859,14 +1859,11 @@ oom:
>>  		return;
>>  	}
>>  
>> -	mc_spec = kmalloc(0x200, GFP_ATOMIC);
>> +	mc_spec = kzalloc(0x200, GFP_ATOMIC);
>>  	if (mc_spec == NULL)
>>  		goto oom;
>>  	mc_other = mc_spec + (0x100 >> 2);
>
> This sure looks wrong as it sets a pointer
> to unallocated memory.
>
>> -	memset(mc_spec, 0, 0x100);
>> -	memset(mc_other, 0, 0x100);
>
> So this does a memset of random memory.
>

Huh? mc_spec and mc_other are u32*, we allocate 0x200 = 512 bytes = 128
u32s, and pointer arithmetic makes mc_other point to the latter 64. Then
the memory is cleared 256 bytes at a time.

It's unusual and slightly obfuscated code, but I don't think it's
wrong. 

>
> 	for (i = 0; i < 0x100; i += 4) {
> 		wrl(mp, SPECIAL_MCAST_TABLE(mp->port_num) + i, mc_spec[i >> 2]);
> 		wrl(mp, OTHER_MCAST_TABLE(mp->port_num) + i, mc_other[i >> 2]);
> 	}

I'd probably have written that as

for (i = 0; i < 64; ++i) {
	wrl(mp, SPECIAL_MCAST_TABLE(mp->port_num) + 4*i, mc_spec[i]);
	wrl(mp, OTHER_MCAST_TABLE(mp->port_num) + 4*i, mc_other[i]);
}

but again, I don't think it's wrong [haven't checked what
SPECIAL_MCAST_TABLE/OTHER_MCAST_TABLE do, though].

Rasmus
