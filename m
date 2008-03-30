From: Bernard Pidoux <bpidoux@free.fr>
Subject: Re: [AX25] kernel panic
Date: Sun, 30 Mar 2008 19:38:51 +0200
Message-ID: <47EFD02B.8080006@free.fr>
References: <47E2EC1B.9070405@free.fr> <20080322113620.GA3213@ami.dom.local> <47E68CA1.2040904@free.fr> <20080324205104.GA3721@ami.dom.local> <47E8FCE2.6000308@free.fr> <20080326183538.GA14266@ami.dom.local> <20080328120721.GA11060@ami.dom.local> <47EE3040.3050208@free.fr> <20080329122452.GB3407@ami.dom.local> <47EF529B.8060108@free.fr> <20080330091636.GA2847@ami.dom.local>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000104010900000809000200"
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Jarek Poplawski <jarkao2@o2.pl>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g19.free.fr ([212.27.42.35]:46848 "EHLO smtp5-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751645AbYC3Ri5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Mar 2008 13:38:57 -0400
In-Reply-To: <20080330091636.GA2847@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000104010900000809000200
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


Jarek Poplawski wrote:

> On Sun, Mar 30, 2008 at 10:43:07AM +0200, Bernard Pidoux wrote:
>> Hi Jarek,
> 
> Hi Bernard,
>> please find attached another collection of data from  
>> /var/log/kernel/info.log that I bziped for it is rather large.
> 
> Thanks again. It looks like ROSE sockets aren't released properly.
> Here is a try to fix this. Could you test it with all previous patches
> present?
> 
> Regards,
> Jarek P.
> 
> (patch #5)
> ---
> 
> diff -Nurp 2.6.24.4-/net/rose/af_rose.c 2.6.24.4+/net/rose/af_rose.c
> --- 2.6.24.4-/net/rose/af_rose.c	2008-01-24 23:58:37.000000000 +0100
> +++ 2.6.24.4+/net/rose/af_rose.c	2008-03-30 10:53:19.000000000 +0200
> @@ -599,17 +599,24 @@ static int rose_release(struct socket *s
>  
>  	if (sk == NULL) return 0;
>  
> +	sock_hold(sk);
> +	sock_orphan(sk);
> +	lock_sock(sk);
>  	rose = rose_sk(sk);
>  
>  	switch (rose->state) {
>  	case ROSE_STATE_0:
> +		release_sock(sk);
>  		rose_disconnect(sk, 0, -1, -1);
> +		lock_sock(sk);
>  		rose_destroy_socket(sk);
>  		break;
>  
>  	case ROSE_STATE_2:
>  		rose->neighbour->use--;
> +		release_sock(sk);
>  		rose_disconnect(sk, 0, -1, -1);
> +		lock_sock(sk);
>  		rose_destroy_socket(sk);
>  		break;
>  
> @@ -634,6 +641,8 @@ static int rose_release(struct socket *s
>  	}
>  
>  	sock->sk = NULL;
> +	release_sock(sk);
> +	sock_put(sk);
>  
>  	return 0;
>  }
> --


Jarek,

It looks like you hit the right target !

There is no more warnings and no more ax25_frames_acked or
sk_ax25_debug.

We only get ax25_create and ax25_release data, plus ax25_make_new when 
there is an AX25 connexion.

cat /var/log/messages | grep 'Mar 30 17' | grep AX...
Mar 30 17:00:58 f6bvp-9 kernel: AX25+ ax25_create, 866, c73a6738, c3300040
Mar 30 17:00:58 f6bvp-9 kernel: AX25- ax25_release, 959, c73a6738, c3300040
Mar 30 17:00:58 f6bvp-9 kernel: AX25+ ax25_create, 866, c73a6738, c3300040
Mar 30 17:00:58 f6bvp-9 kernel: AX25- ax25_release, 959, c73a6738, c3300040
Mar 30 17:01:23 f6bvp-9 kernel: AX25; ax25_make_new, 943, c73a6738, c762a820
Mar 30 17:01:23 f6bvp-9 kernel: AX25= ax25_accept, 1386, c73a6738, 
c762a820, c3300040
Mar 30 17:01:58 f6bvp-9 kernel: AX25+ ax25_create, 866, c73a6f68, c7673ac0
Mar 30 17:01:58 f6bvp-9 kernel: AX25- ax25_release, 959, c73a6f68, c7673ac0
Mar 30 17:01:58 f6bvp-9 kernel: AX25+ ax25_create, 866, c73a6f68, c7673ac0


Please excuse the following questions if you find they are too naive.
Could you tell us how did you suspect ROSE socket from the data 
collected ? and why improperly released ROSE sockets could interfere 
with AX25 ?


Regards,


Bernard P.


--------------000104010900000809000200
Content-Type: application/x-bzip;
 name="AX25.kernel.debug5.bz2"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="AX25.kernel.debug5.bz2"

QlpoOTFBWSZTWbSo9MsAIRdfgAAQQI//+iACAEC7j93EUAXe4egbQAADgzShKpT/TVT89qqp
iYAAAABjRo0AyZDRiNNA0wEnqqUg0HqAyeiNANAAUpSmkYnqemhqPUMIxoDUClJGpk1I1IxA
GgNMIeu6qH4/n3wCPyBGlUOf3VUOfmttVz5bbVeLbbar3c2AMAGLeWnAwA0lZKgDSWyVSWaC
63ADABi3RTgYAaSslQBpLZYGMWTNzi0qoe/Z+93OqHX4qh85ttV8PIeeuTVSqpWtx0SAADMA
DlxcAZhJSkkgBmAAASSSSSSSSSSSSSSAABJJJJJJJJJJJJJJJJJJJJJJJLGM5OSYDFWGGFhX
HGZ3VDdVQ/Lw38Nned+eZNBoYWSNYyyzMKsGCsKvkEa+Pn+2ta9PQGzAv6uko9JRpTJoZCPR
hwX7TA6OHO3HDjhxrTt2555cuXp95kvjD/ZgaJDGDGGDue3tjXbjhxw417cPbnnly5fEnWYq
+4Jk/ZKhhj/1VDQ+wwefB8a0a1nw+Hw555cuXjlr6AjaUfI9h4lGC1ST3oZ1eNatNa8e3bnn
ly5dUkelE66ML78LsJhONdNuOOHDjjty7c88uXLhVD0UOzkJpSndUMOt961rWtdO3Te97bbc
wR8E+cSrxE0qGF+NRgn/CvL15q1rWtePbxve9ttvVVDsrryi0FYT61IYTs0oOCLwi2SHm/HH
HHDiOOOHjxve9tttnZ6OFFuT2YX1JYcGiNMOBYOAnAV5hMz5VDzl71prt459Nt7bb223ipPw
qoZVDoI+hFz6syzO3bt03vbbbb86qHp0ixkpmExhZhDrCmMIy1166+l6+nvvV27Mzu79d99u
mrvhwZKNFFa21N3d1tpZW0IG5uTaZkhoq7cGSjRRWANamc6ysqSTMiQREsssssRNK0UYMCIi
IkKKIJZQiWUqqrKkkzIkERLLLLLETStFGDAiIiJCiiCWUIllYCjeADY7fKqhwBGoI35VD7VI
a3MdRyE9f77+wI49FUN+Kh01UOc+2qhhNVVD7Nb8VD/SofFUPufH6qh/lQ+aqGQjm1VUPHq5
dhWyqhx2aMyqhtVJcdua6qGvry+2qhnUEfKobqh9XII28tUNM9MVDo4VUNXJVQ1v+LuSKcKE
haVHplg=
--------------000104010900000809000200--
