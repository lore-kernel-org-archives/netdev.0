From: Daniel Borkmann <borkmann@iogearbox.net>
Subject: Re: bpf: net/core/filter.c:2115 suspicious rcu_dereference_protected()
 usage!
Date: Wed, 30 Mar 2016 14:38:42 +0200
Message-ID: <56FBC8D2.6080506@iogearbox.net>
References: <56CB29D5.9090000@oracle.com> <20160329125823.GB15048@unicorn.suse.cz> <56FA8935.8030109@iogearbox.net> <56FA93AF.8060001@iogearbox.net> <20160330094224.GC15048@unicorn.suse.cz> <56FBB998.5090504@iogearbox.net> <20160330122418.GD15048@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sasha Levin <sasha.levin@oracle.com>, Jiri Slaby <jslaby@suse.cz>,
	"David S. Miller" <davem@davemloft.net>, ast@plumgrid.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:45777 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751217AbcC3Mit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 08:38:49 -0400
In-Reply-To: <20160330122418.GD15048@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/30/2016 02:24 PM, Michal Kubecek wrote:
> On Wed, Mar 30, 2016 at 01:33:44PM +0200, Daniel Borkmann wrote:
>> On 03/30/2016 11:42 AM, Michal Kubecek wrote:
>>>
>>> I'm just not sure checking if we hold the right lock depending on caller
>>> is worth the extra complexity. After all, what is really needed is to
>>> hold _some_ lock guaranteeing sk_attach_prog() and sk_detach_filter()
>>> are safe so that just changing the condition in both to
>>>
>>>    sock_owned_by_user(sk) || lockdep_rtnl_is_held()
>>
>> It would certainly silence it, but would be less accurate in terms of lock
>> proving as opposed to the diff above. E.g. rntl could be held elsewhere,
>> while someone attaches a socket filter w/o having locked the socket (currently
>> not the case, but it would kind of defeat the purpose of rcu_dereference_protected()
>> here). Was thinking about using a extra socket flag to indicate it's
>> externally managed, but it's not really worth wasting sk's flags bit
>> space just for this corner case.
>
> Originally my reasoning was that to actually hide a locking issue from
> lockdep, this would have to happen every time we get down into the
> function which is unlikely. But thinking about it again, this code path
> is not so frequent and the fuzzers tend to do strange things so that it
> could really happen.

In this case actually nothing too fancy, just seems that filters on tap devices
might not be really used by anyone (issue is already couple of years old).

> Sasha/Jiri, could you test the patch with your testcases? I received it
> corrupted (strange leading whitespaces) so I better add cleaned up
> version below.

Tested this yesterday night on my machine with PROVE_RCU + PROVE_RCU_REPEATEDLY
enabled, and it can easily be triggered with a simple ioctl(tun_fd,
TUN{ATTACH,DETACH}FILTER, ...) on a tap device, and the patch now silences
it. Sorry for the white space damage (should have just attached it), I'd send
it later today.

Thanks,
Daniel
