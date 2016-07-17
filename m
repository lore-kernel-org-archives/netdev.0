From: "Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>
Subject: RE: [PATCH RESEND] iwlwifi, Do not implement thermal zone unless
 ucode is loaded
Date: Sun, 17 Jul 2016 06:13:44 +0000
Message-ID: <0BA3FCBA62E2DC44AF3030971E174FB3466928D5@hasmsx107.ger.corp.intel.com>
References: <1468250301-10357-1-git-send-email-prarit@redhat.com>
 <CANUX_P0AFoM5VEDWDjtvOhNbExu4T1bLWU+uS-EYqoGtu5h2bw@mail.gmail.com>
 <5783E33E.7090205@redhat.com> <1468261650.20877.14.camel@intel.com>
 <20160714092408.GA27271@redhat.com>
 <0BA3FCBA62E2DC44AF3030971E174FB3466901DA@hasmsx107.ger.corp.intel.com>
 <20160715112552.GB6939@redhat.com> <5788D397.9030904@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	linuxwifi <linuxwifi@intel.com>,
	"Coelho, Luciano" <luciano.coelho@intel.com>,
	"Berg, Johannes" <johannes.berg@intel.com>,
	"kvalo@codeaurora.org" <kvalo@codeaurora.org>,
	"Ivgi, Chaya Rachel" <chaya.rachel.ivgi@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Sharon, Sara" <sara.sharon@intel.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>
To: Prarit Bhargava <prarit@redhat.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5788D397.9030904@redhat.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On 07/15/2016 07:25 AM, Stanislaw Gruszka wrote:
> > On Thu, Jul 14, 2016 at 09:44:22AM +0000, Grumbach, Emmanuel wrote:
> >>> If I understad correctly this error happen 100% of the time, not
> >>> only during init. Hence seems there is an issue here, i.e. cur_ucode
> >>> is not marked correctly as IWL_UCODE_REGULAR or
> iwl_mvm_get_temp()
> >>> fail 100% of the time (iwl_mvm_is_tt_in_fw() incorrecly return true on
> Prarit device ? ).
> >>
> >> Cur_ucode will not be IWL_UCODE_REGULAR until you load the firmware
> >> which will happen upon ifup.
> >
> > Then creating thermal_device on ifup looks more reasonable to me.
> > Otherwise we can create device that can be non-functional virtually
> > forever, i.e. when soft RFKILL is enabled. However I admit that
> > creating thermal_device when HW is detected has some advantages too.
> 
> That's my plan right now.  Unfortunately something else in the kernel seems
> recently broken and is preventing me from testing.  I will get back to this
> early next week.
> 

But we already said that this won't work since you may have the device enabled upon boot and then disabled. So unless you unregister the thermal zone subsystem upon wifi disable, you won't solve the problem. Kalle and Luca already refused that solution.

I glanced (again) at the thermal zone API and since it allows to return an int, the subsystem itself should handle the failures and / or the userspace problems. The API itself is awful, it has no documentation whatsoever, even not variable names, but only types... You can't really blame the subsystem users to assume that a method that can return an int can't fail where the out values is passed by a pointer. Of course, you have to guess that this is the expected behavior, since you don't have any hint about the meaning of the parameters.
I think that the right place to "fix" this problem is to fix the subsystem. This way, you will fix it for iwlwifi and for any (future) other users that may fall into the trap opened by the API itself.
