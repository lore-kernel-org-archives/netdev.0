From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH] netns: correctly use per-netns ipv4 sysctl_tcp_mem
Date: Fri, 20 Jul 2012 19:22:02 -0300
Message-ID: <5009DA0A.4010401@parallels.com>
References: <4FFA7495.5070702@huawei.com>
	<20120709.152100.571089964662155300.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120709.152100.571089964662155300.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 07/09/2012 07:21 PM, David Miller wrote:
> From: Huang Qiang <h.huangqiang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> Date: Mon, 9 Jul 2012 14:05:09 +0800
> 
>> From: Yang Zhenzhang <yangzhenzhang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
>>
>> Now, kernel allows each net namespace to independently set up its levels
>> for tcp memory pressure thresholds.
>>
>> But it seems there is a bug, as using the following steps:
>>
>> [root@host socket]# lxc-start -n test -f config /bin/bash
>> [root@net-test socket]# ip route add default via 192.168.58.2
>> [root@net-test socket]# echo 0 0 0 > /proc/sys/net/ipv4/tcp_mem
>> [root@net-test socket]# scp root-Q0ErXNX1RuabR28l3DCWlg@public.gmane.org:/home/tcp_mem_test .
>>
>> and it still can transport the "tcp_mem_test" file which we hope it
>> would not.
>>
>> It's because inet_init() (net/ipv4/af_inet.c)initialize the
>> tcp_prot.sysctl_mem:
>> tcp_prot.sysctl_mem = init_net.ipv4.sysctl_tcp_mem;
>>
>> So when the protocal is TCP, sk->sk_prot->sysctl_mem(following code)
>> always use the ipv4 sysctl_tcp_mem of init_net namespace rather than
>> it's own net namespace.
>> This patch simply set "prot" equal to net->ipv4.sysctl_tcp_mem when
>> the protocol type is TCP.
>>
>> Signed-off-by: Yang Zhenzhang <yangzhenzhang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> 
> Another regression added by the socket memory cgroup code, BIG
> SURPRISE.
> 

Back from vacations: If I understand the submission correctly, this is
not a regression, since it seems to be only happening when those values
are set inside the network namespace - which was not possible before.

In any case, I believe from what I can see that the fix is already in
the way (haven't seen the whole backlog yet)
