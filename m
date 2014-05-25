From: sumanth <sumantk2@linux.vnet.ibm.com>
Subject: Re: Some clarification regarding rfc3484 (6724) - Rule 8 Prefer smaller
 scope
Date: Mon, 26 May 2014 00:31:10 +0530
Message-ID: <53823DF6.1010505@linux.vnet.ibm.com>
References: <537F4B55.5040305@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>,
	Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp09.in.ibm.com ([122.248.162.9]:51206 "EHLO
	e28smtp09.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751075AbaEYTBR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 May 2014 15:01:17 -0400
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <sumantk2@linux.vnet.ibm.com>;
	Mon, 26 May 2014 00:31:14 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id F2C98394003E
	for <netdev@vger.kernel.org>; Mon, 26 May 2014 00:31:11 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s4PJ1gIJ59441352
	for <netdev@vger.kernel.org>; Mon, 26 May 2014 00:31:42 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s4PJ1AoB027359
	for <netdev@vger.kernel.org>; Mon, 26 May 2014 00:31:11 +0530
In-Reply-To: <537F4B55.5040305@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/23/2014 06:51 PM, sumanth wrote:
> I had configured my local interface as follows :
> ifconfig eth0 inet6 add fe80::1/64
> ifconfig eth0 inet6 add fec0::1/10
>
> And /etc/hosts contains :
> fe80::2 server.org
> fec0::2 server.org
>
> The above two interfaces in /etc/hosts are not configured. Just to get
> the result from getaddrinfo().
>
> So according to rfc3484 , link-local has lower scope when compared to
> site-local .
> So i think fe80::2 should be returned first and then later fec0::2
>
> In my fedora ( any kernel ), getaddrinfo() is preferring site-local
> first instead of link-local.
>
> So when looking into the getaddrinfo() glibc implementation ,  when two
> or more addresses are available (code flow):
> 1) create a udp datagram socket
> 2) connect to the destination addresses returned from gaih_inet ( not
> sorted yet ). This was done inorder to get the source address from the
> kernel (using ipv6_get_saddr_eval() we get the preferred source for 
> each destination). Actually doesnt need the destination to be reachable .
>  #netstat | grep -i udp
> udp        0      0 fec0::1:34236               server.org:http      
> ESTABLISHED
>
> 3) getsockname to get the source address and store in result combo array.
>
> So __connect() to site-local becomes successfull . But __connect() to
> link-local is not successfull .
>
> Hence rfc3484_sort() in glibc changes the order and prefers site-local
> first .
>
> i.e /* Rule 1: Avoid unusable destinations.
>      We have the got_source_addr flag set if the destination is
> reachable.  */
>   if (a1->got_source_addr && ! a2->got_source_addr)
>
> a1->got_source_addr is false because connect to link-local failed.
>
> So my questions are :
> 1) Can this be a problem somewhere around ip6_datagram_connect() [
> because connect fails ]
> 2) Can this be a problem with the parsing of glibc getaddrinfo ? [
> something like sin6_scope_id being not set properly ]
> 3) Or this is the expected behaviour or am i missing out something ?
I was testing one of the tahi testcase :

  DstSelectRule8.seq - Destination Address Selection
                       Check Rule 8(Prefer smaller scopee)

  Rule 8: Prefer smaller scope.
    If Scope(DA) < Scope(DB), then prefer DA.


The configuration was done as shown above. . So link-local was expected.
But returned value was site-local.

- So while looking into the ip6_datagram_connect(), inorder for the
connect() call  to succeed for link-local address, it requires the
sk_bound_dev_if field of the sk to be set. So this can  be done using
setsockopt( fd, SOL_SOCKET, SO_BINDTODEVICE, device , strlen(device) +
1) from the application side / library. 

- But however __connect in glibc getaddrinfo() fails in case of
link-local ( when there are more than 2 address ) . But  in
getaddrinfo.c,  if we add a patch such that   setsockopt() is done
before __connect() and __getsockname() if it is a LINKLOCAL address,
then link-local address is returned first and then later site-local (
which is expected as per tahi testcase ).  i.e rfc3484_sort() goes into
Rule 8 of destination address selection ( otherwise it returns from
Rule1 as source address of link-local wont be set itself as connect() fails)

- But rfc4472 mentions that  Link-local addresses should never be
published in DNS (whether in
   forward or reverse tree), because they have only local (to the
   connected link) significance.

- So whether rfc4472 means that we shouldnt specify link-local address
in /etc/hosts as well ?
- Or it is expected to return site-local first ?  [ If i do setsockopt()
in glibc before connect() iff link-local address, then link-local is
returned first ]. So if it is expected to return link-local , then it is
a bug...


Any help/suggestions would be good.
>
> Any suggestions ?
>
>
> Thank you,
> Sumanth K
