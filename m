From: Vitalii Demianets <vitas@nppfactor.kiev.ua>
Subject: Re: [PATCH] bridge: push blocking slaves to forwarding
	when turning stp off
Date: Wed, 14 Dec 2011 11:32:51 +0200
Message-ID: <201112141132.51867.vitas@nppfactor.kiev.ua>
References: <201112131136.25919.vitas@nppfactor.kiev.ua>
	<20111213161613.0c59ab36@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20111213161613.0c59ab36@nehalam.linuxnetplumber.net>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Wednesday 14 December 2011 02:16:13 Stephen Hemminger wrote:
> On Tue, 13 Dec 2011 11:36:25 +0200
>
> Vitalii Demianets <vitas@nppfactor.kiev.ua> wrote:
> > If there is a slave in blocking state when stp is turned off, that slave
> > will remain in blocking state for indefinitely long time until interface
> > state changed. We should push all blocking slaves into forwarding state
> > after turning stp off.
> >
> > Signed-off-by: Vitalii Demianets <vitas@nppfactor.kiev.ua>
>
> Maybe. But if the port was in the blocking state then STP must have
> decided there was a loop in the network if that port was used.
> Therefore blindly putting the port into forwarding state could cause
> disastrous network flood.
>
>
> The user can force the port back out of blocking state (via sysfs).
>

1) That blocking state in the absence of STP is not stable. It will eventually 
flip to forwarding sooner or later on the first call of 
br_port_state_selection(). For example, when user changes MAC address on 
another slave. Or even worse - when any other slave of the bridge changes its 
carrier state. Don't think user wants such unpredictable state changes.

2) There is also another drawback of not pushing ports into forwarding state 
after turning off USER_STP mode. Possible scenario is:
  a) bridge in USER_STP mode, all ports are in non-forwarding state (blocking, 
learning)
  b) user turns off STP. Without the patch ports are not advanced to the 
forwarding state and are left in the states they are (the timers do not work 
because of USER_STP mode)
  c) The bridge stays in no-carrier state until something happens (carrier 
state transition on one of the slaves, MAC address change etc)

You can say again that in the above two cases user can manually set the state 
of the slaves to forwarding.  But to account all possible cases one should 
always unconditionally do it for all the slaves each time when stp is being 
turned off. So why not to automate the task?

3) The initial intention of the code in br_stp_stop() was to get ports out of 
blocking state when stp is being turned off. It fails to achieve the goal, 
and patch just fixes it.

4) If user turns stp off he clearly indicates that she wants all ports to work 
in stateless mode and that he will deal with possible network loops on 
himself. Should we in that case guess network topology basing on loose 
assumptions and leave ports in unstable blocking state (and they will flip 
eventually to the forwarding state in unpredictable times as mentioned 
above)?

-- 
Vitalii Demianets
