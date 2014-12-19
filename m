From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [RFC PATCH net-next v2 1/1] net: Support for switch port
 configuration
Date: Fri, 19 Dec 2014 10:55:12 +0100
Message-ID: <20141219095512.GH1848@nanopsycho.orion>
References: <54931969.7040209@cumulusnetworks.com>
 <5493293A.2000802@intel.com>
 <54935E28.8050602@cumulusnetworks.com>
 <549362A5.3000808@intel.com>
 <549367CC.2080307@cumulusnetworks.com>
 <CAN+pFwJyfg1+=+tXUpon0Kket56HJ=9BR3XohPhZnaX7hfPgpg@mail.gmail.com>
 <20141219082754.GE1848@nanopsycho.orion>
 <CAN+pFwJAJ71-+MZjJXPbfu5mzMp6AWNxtYR81Lx6siy3D3HfJg@mail.gmail.com>
 <20141219092308.GF1848@nanopsycho.orion>
 <CAN+pFwJr7TvJEW4x_HYPgTEvYGfi+YHgp=5vek2YiU1GLiH6_g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
	"Samudrala, Sridhar" <sridhar.samudrala@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	"Varlese, Marco" <marco.varlese@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: B Viswanath <marichika4@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAN+pFwJr7TvJEW4x_HYPgTEvYGfi+YHgp=5vek2YiU1GLiH6_g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fri, Dec 19, 2014 at 10:35:27AM CET, marichika4@gmail.com wrote:
>On 19 December 2014 at 14:53, Jiri Pirko <jiri@resnulli.us> wrote:
>> Fri, Dec 19, 2014 at 10:01:46AM CET, marichika4@gmail.com wrote:
>>>On 19 December 2014 at 13:57, Jiri Pirko <jiri@resnulli.us> wrote:
>>>> Fri, Dec 19, 2014 at 06:14:57AM CET, marichika4@gmail.com wrote:
>>>>>On 19 December 2014 at 05:18, Roopa Prabhu <roopa@cumulusnetworks.com> wrote:
>>>>>> On 12/18/14, 3:26 PM, Samudrala, Sridhar wrote:
>>><snipped for ease of reading>
>>>>>>>
>>>>>>>
>>>>>>> We also need an interface to set per-switch attributes. Can this work?
>>>>>>>     bridge link set dev sw0 sw_attr bcast_flooding 1 master
>>>>>>> where sw0 is a bridge representing the hardware switch.
>>>>>>
>>>>>>
>>>>>> Not today. We discussed this @ LPC, and one way to do this would be to have
>>>>>> a device
>>>>>> representing the switch asic. This is in the works.
>>>>>
>>>>>
>>>>>Can I assume that on  platforms which house more than one asic (say
>>>>>two 24 port asics, interconnected via a 10G link or equivalent, to get
>>>>>a 48 port 'switch') , the 'rocker' driver (or similar) should expose
>>>>>them as a single set of ports, and not as two 'switch ports' ?
>>>>
>>>> Well that really depends on particular implementation and drivers. If you
>>>> have 2 pci-e devices, I think you should expose them as 2 entities. For
>>>> sure, you can have the driver to do the masking for you. I don't believe
>>>> that is correct though.
>>>>
>>>
>>>In a platform that houses two asic chips, IMO, the user is still
>>>expected to manage the router as a single entity. The configuration
>>>being applied on both asic devices need to be matching if not
>>>identical, and may not be conflicting. The FDB is to be synchronized
>>>so that (offloaded) switching can happen across the asics. Some of
>>>this stuff is asic specific anyway. Another example is that of the
>>>learning. The (hardware) learning can't be enabled on one asic, while
>>>being disabled on another one. The general use cases I have seen are
>>>all involving managing the 'router' as a single entity.  That the
>>>'router' is implemented with two asics instead of a single asic (with
>>>more ports) is to be treated as an implementation detail.  This is the
>>>usual router management method that exists today.
>>>
>>>I hope I make sense.
>>>
>>>So I am trying to figure out what this single entity that will be used
>>>from a user perspective. It can be a bridge, but our bridges are more
>>>802.1q bridges. We can use the 'self' mode, but then it means that it
>>>should reflect the entire port count, and not just an asic.
>>>
>>>So I was trying to deduce that in our switchdevice model, the best bet
>>>would be to leave the unification to the driver (i.e., to project the
>>>multiple physical asics as a single virtual switch device). Thist
>>
>> Is it possible to have the asic as just single one? Or is it possible to
>> connect asics being multiple chips maybe from multiple vendors together?
>
>I didn't understand the first question. Some times, it is possible to

I ment that there is a design with just a single asic of this type,
instead of a pair.

>have a single asic replace two, but its a cost factor, and others that
>are involved.
>
>AFAIK, the answer to the second question is a No. Two asics from
>different vendors may not be connected together. The interconnect
>tends to be proprietary.

Okay. In that case, it might make sense to mask it on driver level.


>
>> I believe that answer is "yes" in both cases. Making two separate asics
>> to appear as one for user is not correct in my opinion. Driver should
>> not do such masking. It is unclean, unextendable.
>>
>
>I am only looking for a single management entity. I am not thinking it
>needs to be at driver level. I am not sure of  any other option apart
>from creating a 'switchdev' that Roopa was mentioning.

Well the thing is there is a common desire to make the offloading as
transparent as possible. For example, have 4 ports of same switch and
put them into br0. Just like that, without need to do anything else
than you would do when bridging ordinary NICs. Introducing some
"management entity" would break this approach.


>
>>
>>>allows any 'switch' level configurations to the bridge in 'self' mode.
>>>
>>>And  then we would need to consider stacking. Stacking differs from
>>>this multi-asic scenario since  there would be multiple CPU involved.
>>>
>>>Thanks
>>>Vissu
>>>
>>>>>
>>>>>>
>>>>>>
>>>>>> --
>>>>>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>>>>>> the body of a message to majordomo@vger.kernel.org
>>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
