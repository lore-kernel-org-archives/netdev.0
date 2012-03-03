From: Glauber Costa <glommer@parallels.com>
Subject: Re: [PATCHv 2] tcp: properly initialize tcp memory limits part 2
 (fix nfs regression)
Date: Sat, 3 Mar 2012 11:16:41 -0300
Message-ID: <4F5227C9.7060209@parallels.com>
References: <1330675173-18968-1-git-send-email-slyich@gmail.com> <4F509150.5060904@redhat.com> <20120302202421.753b36bc@sf.home> <20120302205000.088bf231@sf.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jason Wang <jasowang@redhat.com>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>
To: Sergei Trofimovich <slyich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.parallels.com ([64.131.90.16]:60790 "EHLO mx2.parallels.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753254Ab2CCORz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Mar 2012 09:17:55 -0500
In-Reply-To: <20120302205000.088bf231@sf.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/02/2012 02:50 PM, Sergei Trofimovich wrote:
>>>> The change looks like a typo (division flipped to multiplication):
>>>>> limit = nr_free_buffer_pages() / 8;
>>>>> limit = nr_free_buffer_pages()<<   (PAGE_SHIFT - 10);
>>>
>>> Hi, thanks for the reporting. It's not a typo. It was previously:
>>> sysctl_tcp_mem[1]<<  (PAGE_SHIFT -  7). Looks like we need to do the
>>> limit check before shift the value. Please try the following patch, thanks.
>>
>> Still does not help. I test it by checking sha1sum of a large file over NFS
>> (small files seem to work simetimes):
>>
>>      $ strace sha1sum /gentoo/distfiles/gcc-4.6.2.tar.bz2
>>      ...
>>      open("/gentoo/distfiles/gcc-4.6.2.tar.bz2", O_RDONLY
>>      <HUNG>
>> After a certain timeout dmesg gets odd spam:
>> [  314.848094] nfs: server vmhost not responding, still trying
>> [  314.848134] nfs: server vmhost not responding, still trying
>> [  314.848145] nfs: server vmhost not responding, still trying
>> [  314.957047] nfs: server vmhost not responding, still trying
>> [  314.957066] nfs: server vmhost not responding, still trying
>> [  314.957075] nfs: server vmhost not responding, still trying
>> [  314.957085] nfs: server vmhost not responding, still trying
>> [  314.957100] nfs: server vmhost not responding, still trying
>> [  314.958023] nfs: server vmhost not responding, still trying
>> [  314.958035] nfs: server vmhost not responding, still trying
>> [  314.958044] nfs: server vmhost not responding, still trying
>> [  314.958054] nfs: server vmhost not responding, still trying
>>
>> looks like bogus messages. Might be relevant to mishandled timings
>> somewhere else or a bug in nfs code.
>
> And after 120 seconds hung tasks shows it might be an OOM issue
> Likely caused by patch, as it's a 2GB RAM +4GB swap amd64 box
> not running anything heavy:

That is a bit weird.

First because with Jason's patch, we should end up with the very same 
calculation, at the same exact order, as it was in older kernels.
Second, because by shifting << 10, you should be ending up with very 
small numbers, effectively having tcp_rmem[1] == tcp_rmem[2], and the 
same for wmem.

Can you share which numbers you end up with at 
/proc/sys/net/ipv4/tcp_{r,w}mem ?
