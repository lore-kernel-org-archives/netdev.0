From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 03/16] net: Basic network namespace infrastructure.
Date: Mon, 10 Sep 2007 09:53:55 -0600
Message-ID: <m1ejh6qzxo.fsf@ebiederm.dsl.xmission.com>
References: <m1r6l8x3vq.fsf@ebiederm.dsl.xmission.com>
	<m1myvwx3sf.fsf@ebiederm.dsl.xmission.com>
	<m1ir6kx3mn.fsf_-_@ebiederm.dsl.xmission.com>
	<m1ejh8x3ih.fsf_-_@ebiederm.dsl.xmission.com>
	<46E543A0.7010104@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <46E543A0.7010104-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> (Pavel Emelyanov's message of "Mon,
	10 Sep 2007 17:16:16 +0400")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org> writes:

> Eric W. Biederman wrote:
>
> [snip]
>
>> --- /dev/null
>> +++ b/include/net/net_namespace.h
>> @@ -0,0 +1,68 @@
>> +/*
>> + * Operations on the network namespace
>> + */
>> +#ifndef __NET_NET_NAMESPACE_H
>> +#define __NET_NET_NAMESPACE_H
>> +
>> +#include <asm/atomic.h>
>> +#include <linux/workqueue.h>
>> +#include <linux/list.h>
>> +
>> +struct net {
>
> Isn't this name is too generic? Why not net_namespace?

My fingers went on strike.  struct netns probably wouldn't be bad.
The very long and spelled out version seemed painful.  I don't really
care except that not changing it is easier for me.  I'm happy to do
whatever is considered most maintainable.

>> +	/* Walk through the list backwards calling the exit functions
>> +	 * for the pernet modules whose init functions did not fail.
>> +	 */
>> +	for (ptr = ptr->prev; ptr != &pernet_list; ptr = ptr->prev) {
>
> Good reason for adding list_for_each_continue_reverse :)

Sounds reasonable.

>> +static int register_pernet_operations(struct list_head *list,
>> +				      struct pernet_operations *ops)
>> +{
>> +	struct net *net, *undo_net;
>> +	int error;
>> +
>> +	error = 0;
>> +	list_add_tail(&ops->list, list);
>> +	for_each_net(net) {
>> +		if (ops->init) {
>
> Maybe it's better to do it vice-versa?
> if (ops->init)
>    for_each_net(net)
>        ops->init(net);
> ...

My gut feel says it is more readable with the test on the inside.
Although something like
if (ops->init)
   goto out;

might be more readable.

>> +int register_pernet_device(struct pernet_operations *ops)
>> +{
>> +	int error;
>> +	mutex_lock(&net_mutex);
>> +	error = register_pernet_operations(&pernet_list, ops);
>> +	if (!error && (first_device == &pernet_list))
>
> Very minor: why do you give the name "device" to some pernet_operations?

Subsystems need to be initialized before and cleaned up after network
devices.  We don't have much in the way that needs this distinction,
but we have just enough that it is useful to make this distinction.

Looking at my complete patchset all I have in this category is the
loopback device, and it is important on the teardown side of things
that the loopback device be unregistered before I clean up the
protocols or else I get weird leaks.

Reflecting on it I'm not quite certain about the setup side of things.
I'm on the fence if I need to completely dynamically allocate the
loopback device or if I need to embed it struct net.

There also may be a call for some other special network devices
to have one off instances in each network namespace.    With the
new netlink creation API it isn't certain we need that idiom anymore
but before that point I was certain we would have other network
devices besides the loopback that would care.

Eric
