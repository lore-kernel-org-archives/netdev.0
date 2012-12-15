From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: tc ipt action
Date: Sat, 15 Dec 2012 16:19:29 -0500
Message-ID: <50CCE961.5050204@mojatatu.com>
References: <50C4821D.5090206@gmail.com> <50C9B4BB.9060609@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	pablo@netfilter.org, netfilter-devel@vger.kernel.org
To: Yury Stankevich <urykhy@gmail.com>, shemonc@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:51682 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751745Ab2LOVTc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Dec 2012 16:19:32 -0500
Received: by mail-ie0-f174.google.com with SMTP id c11so7639408ieb.19
        for <netdev@vger.kernel.org>; Sat, 15 Dec 2012 13:19:32 -0800 (PST)
In-Reply-To: <50C9B4BB.9060609@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yury,

I took a brief look and run some quick tests on ubuntu 12.04. I am going
to be lazy and try and involve the netfilter folks.
It seems that if you left out the args to CONNMARK (includes other 
targets like MARK etc) you will succeed - but you get default values.


Example, the following should work for
tc filter add dev eth0 parent ffff: protocol ip u32 match u32 0 0
action ipt -j CONNMARK \
action mirred egress redirect dev ifb0

Here is what the output looks like when you dont pass the parameters.

-------
j@ubuntu:~$ sudo tc filter show dev eth0 parent ffff:
filter protocol ip pref 1 u32
filter protocol ip pref 1 u32 fh 800: ht divisor 1
filter protocol ip pref 1 u32 fh 800::800 order 2048 key ht 800 bkt 0 
flowid 1:15
   match 0a000015/ffffffff at 12
	action order 1: tablename: mangle  hook: NF_IP_PRE_ROUTING
	target  MARK and 0xffffffff
	index 2 ref 1 bind 1

filter protocol ip pref 49149 u32
filter protocol ip pref 49149 u32 fh 804: ht divisor 1
filter protocol ip pref 49149 u32 fh 804::800 order 2048 key ht 804 bkt 
0 flowid 1:12
   match 00000000/00000000 at 0
	action order 33: tablename: mangle  hook: NF_IP_PRE_ROUTING
	target  CONNMARK and 0x0
	index 123 ref 1 bind 1
----------------

Pablo, Hasan Chowdhury tells me this broke after iptable 1.4.10
Hasan also sent me a small patch to fake "xt" instead of "ipt" - but i 
think there's more than meets the eye here; some interface we are using 
to talk to xtables on user space seems to have changed.

cheers,
jamal

On 12-12-13 05:58 AM, Jamal Hadi Salim wrote:
> Yury,
>
> This appears to be an ABI breakage on iptables/netfilter side.
> I will look at it (and hopefully fix it) over the weekend.
>
> cheers,
> jamal
>
> On 12-12-09 07:20 AM, Yury Stankevich wrote:
>> Hello,
>>
>> i not sure this is correct list, please advise if not.
>>
>> i'm trying to use ipt action, and got a problem:
>>
>> #tc filter add dev eth0 parent ffff: protocol ip u32 match u32 0 0
>> action ipt -j CONNMARK --restore-mark action mirred egress redirect
>> dev ifb0
>> -> bad action type ipt
>>
>> from strace:
>> open("/usr/lib/tc//m_gact.so", O_RDONLY) = -1 ENOENT (No such file or
>> directory)
>> write(2, "bad action type ipt\n", 20bad action type ipt
>>
>> well. i'm trying to use xt:
>> #tc filter add dev eth0 parent ffff: protocol ip u32 match u32 0 0
>> action xt -j CONNMARK --restore-mark action mirred egress redirect dev
>> ifb0
>> xt: unrecognized option '--restore-mark'
>>
>> from strace:
>> open("/lib/xtables/libxt_CONNMARK.so", O_RDONLY) = 4
>> read(4,
>> "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0\200\6\0\0004\0\0\0"...,
>> 512) = 512
>> fstat64(4, {st_mode=S_IFREG|0644, st_size=9756, ...}) = 0
>> mmap2(NULL, 12548, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 4, 0)
>> = 0xf76f3000
>> mmap2(0xf76f5000, 8192, PROT_READ|PROT_WRITE,
>> MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 4, 0x1) = 0xf76f5000
>> close(4)                                = 0
>> mprotect(0xf76f5000, 4096, PROT_READ)   = 0
>> socket(PF_INET, SOCK_RAW, IPPROTO_RAW)  = 4
>> fcntl64(4, F_SETFD, FD_CLOEXEC)         = 0
>> lstat64("/proc/net/ip_tables_names", {st_mode=S_IFREG|0440, st_size=0,
>> ...}) = 0
>> statfs64("/proc/net/ip_tables_names", 84, {f_type="PROC_SUPER_MAGIC",
>> f_bsize=4096, f_blocks=0, f_bfree=0, f_bavail=0, f_files=0, f_ffree=0,
>> f_fsid={0, 0}, f_namelen=255, f_frsize=4096}) = 0
>> getsockopt(4, SOL_IP, 0x43 /* IP_??? */,
>> "CONNMARK\0\367\f\300\0\0\0po\367l8p\367\364/p\367:}\302\1", [30]) = 0
>> close(4)                                = 0
>> write(2, "xt: unrecognized option '--resto"..., 41xt: unrecognized
>> option '--restore-mark'
>>
>> so... i make something wrong or this is a bug ?
>>
>> ps: 3.6.8 kernel 64 bit kernel with 32 bit userspace, iproute 20121001
>> from debian-experimental,
>> module act_ipt is loaded.
>> pps: please, cc me in reply.
>>
>>
>
