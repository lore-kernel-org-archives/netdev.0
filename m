From: Vishwanath Pai <vpai@akamai.com>
Subject: Re: [PATCH iptables 3/3] libxt_hashlimit: iptables-restore does not
 work as expected with xt_hashlimit
Date: Tue, 12 Jul 2016 15:29:11 -0400
Message-ID: <57854507.7080603@akamai.com>
References: <20160602001759.GF1644@akamai.com> <20160623102511.GA10493@salvia>
 <576D7AD2.6050107@akamai.com> <20160625093924.GC1289@salvia>
 <577C14D2.3020005@akamai.com> <577D859F.2000003@akamai.com>
 <20160708115409.GA17275@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, kadlec@blackhole.kfki.hu,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	johunt@akamai.com, netdev@vger.kernel.org, pai.vishwain@gmail.com
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20160708115409.GA17275@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/08/2016 07:54 AM, Pablo Neira Ayuso wrote:
> We have to keep the existing behaviour. Yes, it's broken or ambiguos
> but there may be people outthere relying on this.
> 
> What I think we can do to resolve this scenario that you describe
> abobe is to provide a new option:
> 
>         --hashlimit-exclusive
> 
> this turns on a flag in the configuration that results in a bail out
> if any of these two happens:
> 
> 1) there is an existing hashlimit with that name already.
> 2) someone tries to add a hashlimit with a clashing name with no
>    --hashlimit-exclusive.
> 
> So the --hashlimit-exclusive just makes sure the user gets a unique
> name and silly things don't happen.
> 
> If not specified, we rely on the existing (broken) behaviour.
> 

Bailing out if another rule of the same name exists is not an option
right now. Case1 and case2 will look exactly the same to the kernel
module, if you look at the dmesg call for case2 hashlimit_mt_check for
the new rule is called first and then the old rule is deleted so as far
as the kernel module is concerned it appears like someone is adding a
new rule with same name as the existing rule.

Adding --hashlimit-exclusive will solve case 1 but it will error out for
case 2 as well. In case 1 the user is indeed trying to add a rule with
the same name as an existing rule and we can bail out, but in case2 we
are merely restoring it to its original state. But the kernel module
won't be able to differentiate between case1 and case2 because we have
no way of telling whether a user is adding another rule or restoring it.
So if a user tries case2 with --hashlimit-exclusive then
iptables-restore will fail which will be totally unexpected.

One thing we can do to fix this is to make procfs file creation
optional. Right now --hashlimit-name is a mandatory option, I think we
can make this optional so that no proc file is created if the option is
not specified. This will work perfectly with --hashlimit-update and with
both case1 and case2.

>>> > > 2) Replace an iptables rule with iptables-restore
>>> > > 
>>> > > $ iptables -A chain1 -m hashlimit --hashlimit-above 200/sec \
>>> > >   --hashlimit-mode srcip --hashlimit-name hashlimit1 -j DROP
>>> > > 
>>> > > $ iptables-save > /tmp/hashlimit
>>> > > 
>>> > > $ vi /tmp/hashlimit (edit 200/s to 300/s)
>>> > > 
>>> > > $ iptables-restore < /tmp/hashlimit
>>> > > 
>>> > > $ dmesg -c
>>> > > [ 1585.411093] hashlimit_mt_check for rule hashlimit1
>>> > > [ 1585.418948] hashlimit_mt_destroy on hashlimit1
> For this case, you rename your enhance-proc option to:
> 
>         --hashlimit-update
> 
> as I proposed, and remove the /proc entry rename logic.
> 

I will remove the proc entry rename logic and change the option to
--hashlimit-update. This will work for both the cases provided we make
the procfs file creation optional. If a user specifies --hashlimit-name
then we fall back to the old behavior.

>>> > > In case 1 there exists two rules with the same name but we cannot have
>>> > > procfs files for both of the rules since they have to exist in the same
>>> > > directory. In case 2 there will be only one rule but there is a small
>>> > > window where two rules with same name exist. We cannot differentiate
>>> > > this from case 1. In both the cases we get the call for
>>> > > hashlimit_mt_check for the new rule before the old rule is deleted.
>>> > > 
>>> > > Without the rename feature I do not know how to correctly handle the
>>> > > scenario where two rules with different parameters but the same name exist.
> With the explicit new options, we can indeed know where to go. If no
> options are specified, we just keep behaving in the same (broken) way
> that we provide now.
> 
> This is the way hashlimit has been working since day one
> 
> Does this sound good to you?
> 
> Thanks for not giving up on sorting out this problem.

No problem, this turned out to be trickier to solve than I originally
expected. Please let me know what you think about what I proposed above,
I will send a V2 after that.

Thanks,
Vishwanath

