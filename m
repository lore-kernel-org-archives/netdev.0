From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: Re: [RFC] [PATCH 3/3] enable IP multicast when bonding IPoIB devices
Date: Wed, 04 Oct 2006 17:25:08 +0200
Message-ID: <4523D254.9060006@voltaire.com>
References: <Pine.LNX.4.64.0609261309540.24189@zuben> <Pine.LNX.4.64.0609261317460.24189@zuben> <200609262340.k8QNeVZt030301@death.nxdomain.ibm.com> <15ddcffd0609271312m3a4f9613ke3d81695684ca523@mail.gmail.com> <200609281743.k8SHhoZt014879@death.nxdomain.ibm.com> <4522605E.8000208@voltaire.com> <200610032310.k93NAGZt003069@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from taurus.voltaire.com ([193.47.165.240]:35202 "EHLO
	taurus.voltaire.com") by vger.kernel.org with ESMTP
	id S1161239AbWJDPZW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Oct 2006 11:25:22 -0400
To: Jay Vosburgh <fubar@us.ibm.com>
In-Reply-To: <200610032310.k93NAGZt003069@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Vosburgh wrote:
> Or Gerlitz <ogerlitz@voltaire.com> wrote:
> 
>> Sorry, but I don't follow... by saying "would be ideal to do ***it*** this
>> way in all cases" what exactly is the "it" you are referring to?
> 
> 	It refers to:
> 
>>>>>         You almost want to have some kind of call to induce a reload
>>>>> from scratch of the multicast filter settings (along with whatever else
>>>>> might be necessary to alter the hardware type on the fly), to be called
>>>>> by bonding at the time the first slave is added (since slave adds happen
>>>>> in user context, and can therefore hold rtnl as required by most of the
>>>>> multicast address handling code).  That seems less hassle than having to
>>>>> specify the hardware type and address length at module load time.
> 
> 	Having this would eliminate the need to specify the hardware
> type at load time, and would allow changing of the hardware type at
> enslave time, rather than at device up time.  This requires fewer
> changes to other things, like the initscripts or ifenslave.
> 
> 	The ideal would be to allow changing of hardware type at
> literally any time, allowing failover across dissimilar hardware types.
> That's a lot more complicated, and has a smaller pool of potential uses.

Thanks for the clarification. I would prefer first trying to go in the 
direction you suggest below of changing the ifenslave program and the 
kernel bonding code to allow for enslaving while the bonding device is 
not UP.


>> 1st, your current recommendation to solve the link layer address
>> computation of multicast groups joined by the stack before any enslavement
>> actually takes place, is to instrument the bonding code such that it would
>> be possible to enslave devices when the bonding device is not "up" yet.
>>
>> 2nd, the change need to be worked out in the bonding sysfs code, the
>> ifenslave program but ***also*** in packages such as /sbin/ifup and
>> friends.
> 
> 	Correct.  The necessary changes to initscript and sysconfig are
> probably the most complex piece to organize (not necessarily the hardest
> to implement, but rather the most troublesome to deploy, as it
> introduces an API change).

Looking on the sysconfig package, some tools eg /sbin/if{up,down,status} 
use ifenslave which is in turn provided by the iputils package.

My understanding is that changing ifenslave and the bonding kernel code 
to allow for enslaving while master is not up is enough, so actually no 
change is needed to the sysconfig tools, correct?

I have now removed the two assertions in the bonding code on enslaving 
while master is not up and manage to work fine with IPoIB slave devices 
and ***without*** the two module params!

When you have the most troublesome to deploy, the troubles you refer to 
is make sure that the distros would include ***both*** the bonding 
kernel changes and use an iputils package which has the ifenslave changes?

> 	Yes, ifenslave is still supported.  It probably will be
> obsoleted some day (or replaced with a script that uses sysfs), but not
> anytime soon.  As far as I know, all current distros use ifenslave to
> configure bonding.

Cool, thanks for bringing this into my attention... I understand now my 
patch set should also handle the ifenslave.c source that comes with the 
kernel (eg to allow for not setting the hw address etc)

Or.

