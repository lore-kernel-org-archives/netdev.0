From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 03/16] net: Basic network namespace infrastructure.
Date: Mon, 10 Sep 2007 00:40:15 -0600
Message-ID: <m1abrvrpkg.fsf@ebiederm.dsl.xmission.com>
References: <OF55551EA4.A3E6920C-ON65257352.001D6A3E-65257352.001FBEA7@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Krishna Kumar2 <krkumar2-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <OF55551EA4.A3E6920C-ON65257352.001D6A3E-65257352.001FBEA7-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>
	(Krishna Kumar's message of "Mon, 10 Sep 2007 11:16:44 +0530")
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

Krishna Kumar2 <krkumar2-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org> writes:

> Eric W. Biederman wrote on 09/09/2007 02:45:34 AM:
>
> Hi Eric,
>
>> +static int register_pernet_operations(struct list_head *list,
>> +                  struct pernet_operations *ops)
>> +{
>> <snip>
>> +out:
>> +   return error;
>> +
>> +out_undo:
>> +   /* If I have an error cleanup all namespaces I initialized */
>> +   list_del(&ops->list);
>> +   for_each_net(undo_net) {
>> +      if (undo_net == net)
>> +         goto undone;
>> +      if (ops->exit)
>> +         ops->exit(undo_net);
>> +   }
>> +undone:
>> +   goto out;
>> +}
>
> You could remove "undone" label (and associated) goto with a "break".

I could but there is there is no guarantee that the for_each_net macro is
implemented with standard C looping construct such that break will work,
and in one of the earlier versions that wasn't the case.  So my paranoia
says an explicit label safer and just as clear.

>> +static void unregister_pernet_operations(struct pernet_operations *ops)
>> +{
>> +   struct net *net;
>> +
>> +   list_del(&ops->list);
>> +   for_each_net(net)
>> +      if (ops->exit)
>> +         ops->exit(net);
>> +}
>
> Don't you require something like for_each_net_backwards to 'exit' in
> reverse order? Same comment for unregister_subnet_subsys(). Should this
> be done for failure in register_pernet_operations too?

There are no ordering guarantees between the initialization and
cleanup of different network namespaces.   The only real guarantee
is that the initial network namespace is always present.  Which
means any order will work so always doing it in a forwards order
in the list should be fine.

Eric
