From: Cong Wang <cwang@twopensource.com>
Subject: Re: [Patch net-next] fib: move fib_rules_cleanup_ops() under rtnl lock
Date: Tue, 31 Mar 2015 10:56:33 -0700
Message-ID: <CAHA+R7MQGH=xbjc6U6VK_HAaTRRd=dz=sSk-VjisZeW272MSKw@mail.gmail.com>
References: <1427403769-31208-1-git-send-email-xiyou.wangcong@gmail.com>
	<55147E5D.2070600@redhat.com>
	<CAHA+R7P4-y4o5WuUwzfwd+LrrkdRdo2=UfXzYdgTrJ63qkaTVg@mail.gmail.com>
	<55148576.1010303@redhat.com>
	<CAHA+R7Na0BO=rQwFNy-M6pa=TfUXuMDiiwNzsevPpt5CUF=mqQ@mail.gmail.com>
	<CAHA+R7MKNcOOiAsV7iQ2WT=sXCmaM0FuJ0OuY_S8reP2K8hN=w@mail.gmail.com>
	<55149A99.6040704@redhat.com>
	<20150327120135.GC12265@casper.infradead.org>
	<CAHA+R7MJTz1-F2v1c+ZEkVQ_JX0Ey5dGAmCjR_N8rvVPbuM0Tg@mail.gmail.com>
	<5515C6C4.4080200@redhat.com>
	<CAHA+R7Puss-BUG0gFdw+FnbaiXE6Rx=FJ8ccJ2JyJdNMz7H2bQ@mail.gmail.com>
	<5515D5E0.2060800@redhat.com>
	<CAHA+R7OC4dcOZaM1HJ_Z8xbkj0ic+P5APC91=dJnw9EXq3eu2Q@mail.gmail.com>
	<5519E40F.6090708@redhat.com>
	<CAHA+R7MRhvwUcDqAPFRpO8JiEizp_EhUwKyK31MbfMOV=YpW7w@mail.gmail.com>
	<551A101C.8080005@redhat.com>
	<CAHA+R7Pg6K2horjg1wCCxyVqAcb0L7T3v=mnDnpb2Vqa-8VEfg@mail.gmail.com>
	<551AD9C8.4090809@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Graf <tgraf@suug.ch>, Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:33823 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752769AbbCaR4d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2015 13:56:33 -0400
Received: by iedfl3 with SMTP id fl3so25423629ied.1
        for <netdev@vger.kernel.org>; Tue, 31 Mar 2015 10:56:33 -0700 (PDT)
In-Reply-To: <551AD9C8.4090809@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 31, 2015 at 10:30 AM, Alexander Duyck
<alexander.h.duyck@redhat.com> wrote:
>
> On 03/31/2015 09:47 AM, Cong Wang wrote:
>>
>> On Mon, Mar 30, 2015 at 8:10 PM, Alexander Duyck
>> <alexander.h.duyck@redhat.com> wrote:
>>>
>>> On 03/30/2015 05:12 PM, Cong Wang wrote:
>>>>
>>>> 2) remove the unnecessary rules_mod_lock
>>>>
>>>> Thanks.
>>>
>>>
>>> Please define "unnecessary" as we have had a bit of back and forth on how
>>> our views can differ there.  As far as I know it still has to be held for
>>> the fib_rule_ops list manipulation, specifically the call to
>>> list_del_rcu.
>>> However, it doesn't need to be held when we call fib_rules_cleanup_ops.
>>>
>> Look at where rules_mod_lock are held: either when the net is initialized
>> or when unregistering, neither of them really needs this per netns lock:
>> new netns is not ready to expose;
>> concurrent unregistering is prevented by upper layer locking,
>> readers (lookup_rules_ops) hold RCU but we already should hold rtnl lock
>> (after patch of course).
>
>
> I would have almost agreed with you, however I noticed that decnet doesn't
> seem to follow the same rules as the rest of the callers to
> fib_rules_register.  It will simply call into module_init -> decnet_init ->
> dn_fib_init -> dn_fib_rules_injt -> fib_rules_register(&init_net).  It
> probably just needs to be rewritten to use
> register_pernet_subsys/unregister_pernet_subsys, or correctly use the
> net_mutex, and then you could probably go head and tear out the
> rules_mod_lock since they would all be covered under the net_mutex.
>

Good catch, or it can simply hold rtnl lock in module init path.
Anyway, it is for net-next.
