From: James Morris <jmorris@redhat.com>
Subject: Re: Remote DoS vulnerability in Linux kernel 2.6.x (fwd)
Date: Wed, 30 Jun 2004 15:11:25 -0400 (EDT)
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <Xine.LNX.4.44.0406301507320.32316-100000@thoron.boston.redhat.com>
References: <Xine.LNX.4.44.0406301423320.32212-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, Arjan van de Ven <arjanv@redhat.com>,
        "David S. Miller" <davem@redhat.com>, <kuznet@ms2.inr.ac.ru>,
        =?iso-2022-jp?Q?YOSHIFUJI_Hideaki_=2F_=1B$B5HF#1QL=40=1B=28B?= <yoshfuji@linux-ipv6.org>
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: netfilter-devel@lists.netfilter.org, Harald Welte <laforge@netfilter.org>
In-Reply-To: <Xine.LNX.4.44.0406301423320.32212-100000@thoron.boston.redhat.com>
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org

FYI, I have audited options parsing code in TCP, IPv4 input and Netfilter 
for any similar problems and not found any.  Further review would be 
useful (I have not looked at the IPv6 header parsing for example).


On Wed, 30 Jun 2004, James Morris wrote:
> ---------- Forwarded message ----------
> Date: Wed, 30 Jun 2004 12:57:17 +0200
> From: Adam Osuchowski <adwol@polsl.gliwice.pl>
> To: bugtraq@securityfocus.com
> Subject: Remote DoS vulnerability in Linux kernel 2.6.x
> 
> 1. Overview
> -----------
> 
> There is a remotely exploitable bug in all Linux kernel 2.6 series due to
> using incorrect variable type. Vulnerability is connected to netfilter
> subsystem and may cause DoS. It's disclosed only when using iptables with
> rules matching TCP options (i.e.  --tcp-option). There is no difference
> what action is taking up by matching rule.
> 
> Vulnerability was detected on i386 architecture. The other ones weren't tested
> but it seems to be vulnerable too.
> 
> 2. Details
> ----------
> 
> Problem lies in tcp_find_option() function (net/ipv4/netfilter/ip_tables.c).
> There is local array `opt' defined as:
> 
>     char opt[60 - sizeof(struct tcphdr)];
> 
> which contains TCP options extracted from packet. Function mentioned above
> searches for specified option in this array.
> 
> Options in TCP packet, with some exceptions, are organized in the following
> way:
> 
> 	Octet no.	Length	Field
> 	-----------------------------
> 		0	1	Opcode
> 		1	1	Length of all option (N + 2)
> 		2	N	Params
> 
> 
> The function iterates over options in array:
> 
>     for (i = 0; i < optlen; ) {
> 	    if (opt[i] == option) return !invert;
> 	    if (opt[i] < 2) i++;
> 	    else i += opt[i+1]?:1;
>     }
> 
> moving counter by the option length.
> 
> But, in case the `length' value is greater than 127, the value of this octet
> in `opt' is implicitly casted to char, which results in negative number and
> the loop counter moving back. In some cases it is possible, that counter
> cycles throught the contents of this array infinitely.
> 
> 3. Impact
> ---------
> 
> After sending one suitably prepared TCP packet to victim host, kernel goes
> into infinite loop consuming all CPU resources, rendering the box
> unresponsable. Of course, there is no need to have a shell access to attacked
> host.
> 
> 4. Exploitation
> ---------------
> 
> Example of packet-of-death:
> 
> 0x0000:  4500 0030 1234 4000 ff06 e83f c0a8 0001
> 0x0010:  c0a8 0002 0400 1000 0000 0064 0000 0064
> 0x0020:  7000 0fa0 dc6a 0000 0204 05b4 0101 04fd
> 
> 5. Fix
> ------
> 
> There is only need to change type of `opt' array from signed char to unsigned
> (or, better to u_int8_t) as it was defined in 2.4 kernel or prior to version
> 1.16 of net/ipv4/netfilter/ip_tables.c file.
> 
> --- net/ipv4/netfilter/ip_tables.c.orig	2004-04-04 05:36:47.000000000 +0200
> +++ net/ipv4/netfilter/ip_tables.c	2004-06-24 21:24:26.000000000 +0200
> @@ -1461,7 +1461,7 @@
>  		int *hotdrop)
>  {
>  	/* tcp.doff is only 4 bits, ie. max 15 * 4 bytes */
> -	char opt[60 - sizeof(struct tcphdr)];
> +	u_int8_t opt[60 - sizeof(struct tcphdr)];
>  	unsigned int i;
>  
>  	duprintf("tcp_match: finding option\n");
> 
> 6. Credits
> ----------
> 
> Vulnerability was discovered, identified and fixed by Adam Osuchowski
> and Tomasz Dubinski.
> 
> 

-- 
James Morris
<jmorris@redhat.com>
