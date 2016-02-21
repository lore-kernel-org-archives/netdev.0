From: Konstantin Khlebnikov <khlebnikov-XoJtRXgx1JseBXzfvpsJ4g@public.gmane.org>
Subject: Re: [PATCH] ipv4: in new netns initialize sysctls in net.ipv4.conf.*
	with defaults
Date: Sun, 21 Feb 2016 19:58:33 +0300
Message-ID: <56C9ECB9.6040102@yandex-team.ru>
References: <20160221071102.9686.63148.stgit@buzz>
	<56C9827D.3010103@virtuozzo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
To: Vasily Averin <vvs-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <56C9827D.3010103-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>
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

On 21.02.2016 12:25, Vasily Averin wrote:
> Konstantin,
> I've investigated question with sysctls initialization inside namespaces some time ago.
> IIRC I've found people expect that sysctl values should be inherited from parent namespace.
> It allows node admin to adjust unsafe pre-compiled settings, and prepare adequate defaults
> before creation of namespaces.

Only few sysctls are handled in this manner and they are copied from host,
not parent. This works somehow for flat containers, as soon as you go deeper
this turns into madness. Default settings must be controlled by software who
creates namespaces. For now it must reset all yet-not-known sysctls into sane defaults.

BTW two ipv6 sysctl are special: net.ipv6.conf.default.disable_ipv6 and
net.ipv6.conf.default.autoconf their defaults are controlled by module
parameters and inherited by all namespaces. And this makes sense.

>
> However, there is corner case:
> module with sysctl can be loaded after creation of namespaces.
> In this case namespaces will get pre-compiled sysctl defaults,
> and are not be able to adjust them even if they want to do it.
>
> Thank you,
> 	Vasily Averin
>
> On 21.02.2016 10:11, Konstantin Khlebnikov wrote:
>> Currently initial net.ipv4.conf.all.* and net.ipv4.conf.default.* are
>> copied from init network namespace because static structures are used
>> for init_net. This makes no sense because new netns might be created
>> from any netns. This patch makes private copy also for init netns if
>> network namespaces are enabled. Other sysctls in net.ipv4 and net.ipv6
>> already initialized with default values at namespace creation.
>>
>> Signed-off-by: Konstantin Khlebnikov <khlebnikov-XoJtRXgx1JseBXzfvpsJ4g@public.gmane.org>
>> Fixes: 752d14dc6aa9 ("[IPV4]: Move the devinet pointers on the struct net")
>> ---
>>   net/ipv4/devinet.c |    2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
>> index cebd9d31e65a..9d73d4bbdba3 100644
>> --- a/net/ipv4/devinet.c
>> +++ b/net/ipv4/devinet.c
>> @@ -2290,7 +2290,7 @@ static __net_init int devinet_init_net(struct net *net)
>>   	all = &ipv4_devconf;
>>   	dflt = &ipv4_devconf_dflt;
>>
>> -	if (!net_eq(net, &init_net)) {
>> +	if (IS_ENABLED(CONFIG_NET_NS)) {
>>   		all = kmemdup(all, sizeof(ipv4_devconf), GFP_KERNEL);
>>   		if (!all)
>>   			goto err_alloc_all;
>>
>>


-- 
Konstantin
